#!/usr/bin/env python3
"""Test-only guest probe, delivered over a disposable VM's debug serial console."""
import ctypes as C
import json
import os
from pathlib import Path
import subprocess
import sys


def user_snapshot():
    from PyQt6.QtGui import QCursor
    from PyQt6.QtWidgets import QApplication
    import runpy

    app = QApplication([])
    x = C.CDLL('libX11.so.6')
    ulong = C.c_ulong
    x.XOpenDisplay.restype = C.c_void_p
    x.XOpenDisplay.argtypes = [C.c_char_p]
    display = x.XOpenDisplay(None)
    if not display:
        raise RuntimeError('Cannot open the live X11 display')
    x.XDefaultRootWindow.argtypes = [C.c_void_p]
    x.XDefaultRootWindow.restype = ulong
    root = x.XDefaultRootWindow(display)
    x.XQueryTree.argtypes = [C.c_void_p, ulong, C.POINTER(ulong), C.POINTER(ulong),
                            C.POINTER(C.POINTER(ulong)), C.POINTER(C.c_uint)]
    x.XFetchName.argtypes = [C.c_void_p, ulong, C.POINTER(C.c_void_p)]
    x.XTranslateCoordinates.argtypes = [C.c_void_p, ulong, ulong, C.c_int, C.c_int,
                                      C.POINTER(C.c_int), C.POINTER(C.c_int), C.POINTER(ulong)]
    x.XFree.argtypes = [C.c_void_p]
    x.XInternAtom.argtypes = [C.c_void_p, C.c_char_p, C.c_int]
    x.XInternAtom.restype = ulong
    pid_atom = x.XInternAtom(display, b'_NET_WM_PID', False)
    x.XGetWindowProperty.argtypes = [C.c_void_p, ulong, ulong, C.c_long, C.c_long,
                                    C.c_int, ulong, C.POINTER(ulong), C.POINTER(C.c_int),
                                    C.POINTER(ulong), C.POINTER(ulong), C.POINTER(C.c_void_p)]
    windows = []

    def visit(window, depth=0):
        if depth > 5:
            return
        name = C.c_void_p()
        if x.XFetchName(display, window, C.byref(name)) and name.value:
            title = C.string_at(name).decode(errors='replace')
            x.XFree(name)
            px, py, child = C.c_int(), C.c_int(), ulong()
            x.XTranslateCoordinates(display, window, root, 0, 0,
                                    C.byref(px), C.byref(py), C.byref(child))
            actual_type, count, remaining = ulong(), ulong(), ulong()
            actual_format, data = C.c_int(), C.c_void_p()
            x.XGetWindowProperty(display, window, pid_atom, 0, 1, False, 0,
                                 C.byref(actual_type), C.byref(actual_format), C.byref(count),
                                 C.byref(remaining), C.byref(data))
            pid = C.cast(data, C.POINTER(ulong))[0] if count.value and data.value else 0
            if data.value:
                x.XFree(data)
            windows.append({'title': title, 'x': px.value, 'y': py.value, 'pid': pid})
        r, parent, children, count = ulong(), ulong(), C.POINTER(ulong)(), C.c_uint()
        if x.XQueryTree(display, window, C.byref(r), C.byref(parent),
                        C.byref(children), C.byref(count)):
            for index in range(count.value):
                visit(children[index], depth + 1)
            if children:
                x.XFree(children)

    visit(root)
    screen = app.primaryScreen().geometry()
    pointer = QCursor.pos()
    result = {'width': screen.width(), 'height': screen.height(),
              'pointer': [pointer.x(), pointer.y()], 'windows': windows}
    welcome = next((w for w in windows if w['title'] == 'Welcome to NeOS'), None)
    if welcome:
        # Compute the button's layout using the installed widget code, without
        # showing a second window or invoking its handler. Input goes through QEMU.
        widget = runpy.run_path('/usr/local/bin/neos-welcome-app')['NeosWelcome']()
        widget.ensurePolished()
        widget.layout().activate()
        point = widget.primary_button.mapTo(widget, widget.primary_button.rect().center())
        result['install_button'] = [welcome['x'] + point.x(), welcome['y'] + point.y()]
    result['input_devices'] = subprocess.run(['xinput', 'list', '--short'],
                                             text=True, capture_output=True).stdout
    print(json.dumps(result))


def probe(mode):
    if mode == 'snapshot':
        # Recover the actual live user's display/auth, including SDDM's temporary
        # Xauthority location. Do not guess :0 or change the running session.
        environment = None
        for process in Path('/proc').glob('[0-9]*'):
            try:
                command = (process / 'cmdline').read_bytes().split(b'\0')
                if b'/usr/local/bin/neos-welcome-app' not in command:
                    continue
                if process.stat().st_uid != 1000:
                    continue
                environment = dict(item.split(b'=', 1) for item in
                                   (process / 'environ').read_bytes().split(b'\0') if b'=' in item)
                break
            except (OSError, ValueError):
                continue
        if environment is None:
            raise RuntimeError('The live welcome application is not running yet')
        keys = (b'DISPLAY', b'XAUTHORITY', b'DBUS_SESSION_BUS_ADDRESS', b'XDG_RUNTIME_DIR',
                b'XDG_SESSION_TYPE', b'QT_SCALE_FACTOR', b'QT_AUTO_SCREEN_SCALE_FACTOR')
        assignments = [os.fsdecode(key + b'=' + environment[key]) for key in keys if key in environment]
        command = ['runuser', '-u', 'liveuser', '--', 'env', *assignments,
                   'python3', __file__, 'user-snapshot']
        completed = subprocess.run(command, capture_output=True, text=True, timeout=45)
        if completed.returncode:
            raise RuntimeError(completed.stderr[-2000:])
        return json.loads(completed.stdout)
    if mode == 'installer':
        process = subprocess.run(['pgrep', '-x', 'calamares'], capture_output=True, text=True)
        result = {'pids': process.stdout.split(), 'snapshot': probe('snapshot')}
        result['launcher_log'] = Path('/home/liveuser/.cache/neos-installer.log').read_text()[-4000:] \
            if Path('/home/liveuser/.cache/neos-installer.log').exists() else ''
        result['processes'] = []
        for entry in Path('/proc').glob('[0-9]*'):
            try:
                arguments = (entry / 'cmdline').read_bytes().split(b'\0')
                if not any(b'kdialog' in arg or arg == b'/usr/local/bin/neos-welcome'
                           or arg.endswith(b'/calamares') for arg in arguments[:2]):
                    continue
                result['processes'].append({'pid': int(entry.name),
                                            'args': [os.fsdecode(arg) for arg in arguments if arg],
                                            'wait': (entry / 'wchan').read_text()})
            except OSError:
                continue
        result['temporary_logs'] = {str(path): path.read_text(errors='replace')[-4000:]
                                    for path in Path('/tmp').glob('neos-installer.*') if path.is_file()}
        return result
    raise ValueError(mode)


if __name__ == '__main__':
    if sys.argv[1] == 'user-snapshot':
        user_snapshot()
    else:
        print(json.dumps(probe(sys.argv[1])))
