#!/usr/bin/env python3
"""Boot an unmodified ISO and verify real absolute input and its installer button.

Uses a debug serial shell enabled only on this test VM's kernel command line.
The ISO is unchanged, no host directory is mounted, and only a disposable disk
is attached. BIOS/UEFI bootloader tests remain separate.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import re
import select
import socket
import subprocess
import tempfile
import time
import uuid


class VM:
    def __init__(self, directory, output, iso):
        self.directory, self.output = Path(directory), output
        self.qmp = None
        self.serial = None
        self.process = None
        self.serial_log = (output / 'serial.log').open('ab', buffering=0)
        self.qemu_log = (output / 'qemu.log').open('wb')
        self.iso = iso

    def start(self):
        for name in ('vmlinuz-linux-lts', 'initramfs-linux-lts.img'):
            subprocess.run(['xorriso', '-osirrox', 'on', '-indev', str(self.iso),
                            '-extract', '/neos/boot/x86_64/' + name,
                            str(self.directory / name)], check=True, stdout=self.qemu_log,
                           stderr=subprocess.STDOUT)
        label = subprocess.check_output(['blkid', '-p', '-s', 'LABEL', '-o', 'value',
                                         str(self.iso)], text=True).strip()
        subprocess.run(['qemu-img', 'create', '-f', 'qcow2', str(self.directory / 'test.qcow2'),
                        '32G'], check=True)
        acceleration = ['-enable-kvm'] if os.access('/dev/kvm', os.W_OK) else ['-accel', 'tcg']
        command = ['qemu-system-x86_64', *acceleration, '-m', '4096', '-smp', '2',
                   '-display', 'none', '-no-reboot', '-monitor', 'none',
                   '-qmp', f'unix:{self.directory}/qmp,server=on,wait=off',
                   '-serial', f'unix:{self.directory}/serial,server=on,wait=off',
                   '-device', 'qemu-xhci', '-device', 'usb-tablet',
                   '-drive', f'file={self.directory}/test.qcow2,if=virtio,format=qcow2',
                   '-cdrom', str(self.iso), '-kernel', str(self.directory / 'vmlinuz-linux-lts'),
                   '-initrd', str(self.directory / 'initramfs-linux-lts.img'),
                   '-append', f'archisobasedir=neos archisolabel={label} '
                   'console=tty0 console=ttyS0,115200 cow_spacesize=4G copytoram=n '
                   'quiet loglevel=3 systemd.debug_shell=ttyS0 '
                   'systemd.mask=serial-getty@ttyS0.service']
        self.process = subprocess.Popen(command, stdin=subprocess.DEVNULL,
                                        stdout=self.qemu_log, stderr=subprocess.STDOUT)
        for name in ('qmp', 'serial'):
            deadline = time.monotonic() + 30
            while not (self.directory / name).exists():
                if self.process.poll() is not None or time.monotonic() > deadline:
                    raise RuntimeError('QEMU failed to start; see qemu.log')
                time.sleep(0.2)
            connection = socket.socket(socket.AF_UNIX)
            connection.settimeout(60)
            connection.connect(str(self.directory / name))
            setattr(self, name, connection)
        self.qmp_reader = self.qmp.makefile('rb')
        self.qmp_reader.readline()
        self.execute('qmp_capabilities')
        self.read_until(b'NEOS-BOOT-OK', 600)
        self.serial.sendall(b'\x03\n')

    def execute(self, command, arguments=None):
        self.qmp.sendall(json.dumps({'execute': command, 'arguments': arguments or {}}).encode() + b'\n')
        while True:
            message = json.loads(self.qmp_reader.readline())
            if 'error' in message:
                raise RuntimeError(message['error'])
            if 'return' in message:
                return message['return']

    def read_until(self, marker, timeout):
        data = bytearray()
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            if self.process.poll() is not None:
                raise RuntimeError('QEMU exited unexpectedly')
            if select.select([self.serial], [], [], 1)[0]:
                chunk = self.serial.recv(65536)
                if not chunk:
                    raise RuntimeError('Guest serial console disconnected')
                self.serial_log.write(chunk)
                data.extend(chunk)
                if marker in data:
                    return bytes(data)
        raise TimeoutError(f'Guest did not report {marker!r}; see serial.log')

    def python(self, code, timeout=60):
        marker = 'NEOS_VM_' + uuid.uuid4().hex
        wrapped = ('import json,traceback\ntry:\n' +
                   '\n'.join(' '+line for line in code.splitlines()) +
                   f'\nexcept Exception as e:\n result={{"error":str(e),"trace":traceback.format_exc()}}\n'
                   f'print("{marker}:"+json.dumps(result),flush=True)\n')
        encoded = base64.b64encode(wrapped.encode()).decode()
        self.serial.sendall(f"python3 -c \"$(printf %s {encoded} | base64 -d)\"\n".encode())
        response = self.read_until((marker + ':').encode(), timeout)
        # The JSON may arrive in a later serial read than the marker.
        payload = response.split((marker + ':').encode())[-1]
        while b'\n' not in payload:
            payload += self.read_until(b'\n', 10)
        result = json.loads(payload.splitlines()[0])
        if isinstance(result, dict) and 'error' in result:
            raise RuntimeError(result['trace'])
        return result

    def probe(self, mode='snapshot'):
        return self.python("import runpy\nns=runpy.run_path('/tmp/neos-vm-guest-probe.py')\n"
                           f"result=ns['probe']({mode!r})")

    def write_guest(self, path, content):
        self.python(f"from pathlib import Path\nPath({path!r}).write_bytes(b'')\nresult=True")
        for offset in range(0, len(content), 500):
            encoded = base64.b64encode(content[offset:offset + 500]).decode()
            self.python("import base64\n"
                        f"with open({path!r},'ab') as f:\n"
                        f" f.write(base64.b64decode({encoded!r}))\nresult=True")

    def screenshot(self, name):
        ppm = self.output / (name + '.ppm')
        self.execute('screendump', {'filename': str(ppm)})
        from PIL import Image
        with Image.open(ppm) as image:
            image.save(self.output / (name + '.png'))
        ppm.unlink()

    def move(self, x, y, width, height):
        self.execute('input-send-event', {'events': [
            {'type': 'abs', 'data': {'axis': 'x', 'value': round(x * 32767 / (width - 1))}},
            {'type': 'abs', 'data': {'axis': 'y', 'value': round(y * 32767 / (height - 1))}},
        ]})

    def close(self):
        if self.process and self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(15)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()
        self.serial_log.close()
        self.qemu_log.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--iso-dir', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--candidate-launcher', type=Path,
                        default=os.environ.get('NEOS_VM_CANDIDATE_LAUNCHER') or None)
    args = parser.parse_args()
    images = list(args.iso_dir.glob('*.iso'))
    if len(images) != 1:
        raise RuntimeError(f'Expected one ISO; found {len(images)}')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='neos-vm-') as directory:
        vm = VM(directory, output, images[0].resolve())
        evidence = {}
        try:
            vm.start()
            print('[PASS] Guest reached graphical.target', flush=True)
            probe = Path(__file__).with_name('vm-guest-probe.py').read_bytes()
            # Serial terminals can truncate long canonical input lines. Deliver
            # the probe in short, acknowledged commands instead of one large line.
            vm.write_guest('/tmp/neos-vm-guest-probe.py', probe)
            if args.candidate_launcher:
                candidate = args.candidate_launcher.read_bytes()
                vm.write_guest('/usr/local/bin/neos-welcome', candidate)
                vm.python("from pathlib import Path\n"
                          "Path('/usr/local/bin/neos-welcome').chmod(0o755)\nresult=True")
                evidence['candidate_launcher_sha256'] = hashlib.sha256(candidate).hexdigest()
            print('[PASS] Guest control channel ready', flush=True)
            deadline = time.monotonic() + 120
            while True:
                try:
                    snapshot = vm.probe()
                    if 'install_button' in snapshot:
                        break
                except RuntimeError:
                    if time.monotonic() > deadline:
                        raise
                if time.monotonic() > deadline:
                    raise TimeoutError('Welcome window did not become available')
                time.sleep(3)
            evidence['welcome'] = snapshot
            print('[PASS] Live welcome window is present', flush=True)
            vm.screenshot('01-welcome')
            width, height = snapshot['width'], snapshot['height']
            evidence['pointer_checks'] = []
            for x, y in ((100, 100), (width - 100, height - 100), snapshot['install_button']):
                vm.move(x, y, width, height)
                time.sleep(0.5)
                actual = vm.probe()['pointer']
                evidence['pointer_checks'].append({'sent': [x, y], 'received': actual})
                if abs(actual[0] - x) > 5 or abs(actual[1] - y) > 5:
                    raise AssertionError(f'Absolute mouse coordinates are misaligned: {(x,y)} -> {actual}')
            print('[PASS] Actual USB tablet pointer aligns at all three positions', flush=True)
            vm.screenshot('02-pointer-on-install')
            for down in (True, False):
                vm.execute('input-send-event', {'events': [
                    {'type': 'btn', 'data': {'down': down, 'button': 'left'}}]})
                time.sleep(0.2)
            deadline = time.monotonic() + 120
            while True:
                installer = vm.probe('installer')
                windows = installer['snapshot']['windows']
                main_window = next((w for w in windows if str(w['pid']) in installer['pids']
                                    and w['visible'] and w['width'] >= 400 and w['height'] >= 300), None)
                if main_window:
                    break
                if time.monotonic() > deadline:
                    evidence['installer'] = installer
                    raise AssertionError('Clicking Install NeOS did not open Calamares')
                time.sleep(3)
            evidence['installer'] = installer
            vm.screenshot('03-calamares-after-mouse-click')
            from PIL import Image
            with Image.open(output / '03-calamares-after-mouse-click.png') as image:
                x, y = max(0, main_window['x']), max(0, main_window['y'])
                crop = image.crop((x, y, min(image.width, x + main_window['width']),
                                   min(image.height, y + main_window['height'])))
                crop.resize((crop.width * 2, crop.height * 2)).save(output / '04-installer-page.png')
            page_text = subprocess.check_output(['tesseract', str(output / '04-installer-page.png'),
                                                 'stdout'], text=True, timeout=30)
            evidence['installer_page_text'] = page_text
            if not re.search(r'\bwelcome\b', page_text, re.I) or not re.search(r'\bnext\b', page_text, re.I):
                raise AssertionError('The visible Calamares window did not show its Welcome/Next page')
            evidence['result'] = 'PASS'
            print(json.dumps(evidence, indent=2), flush=True)
            print('[PASS] Real USB tablet input aligns at three positions and a mouse click opens Calamares')
        except Exception as error:
            evidence.update(result='FAIL', error=str(error))
            print('Guest serial diagnostics:\n' +
                  (output / 'serial.log').read_bytes()[-8000:].decode(errors='replace'), flush=True)
            print('QEMU diagnostics:\n' +
                  (output / 'qemu.log').read_bytes()[-2000:].decode(errors='replace'), flush=True)
            if vm.qmp:
                try:
                    vm.screenshot('failure')
                except Exception:
                    pass
            raise
        finally:
            (output / 'result.json').write_text(json.dumps(evidence, indent=2))
            vm.close()


if __name__ == '__main__':
    main()
