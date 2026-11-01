"""Behavioral regressions for assisted installation; all writes are temporary."""
from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "profile/airootfs/usr/local/bin/neos-autoinstall"
CONFIG = ROOT / "profile/airootfs/etc/calamares"


def bash(code, *args):
    return subprocess.run(["bash", "-c", 'source "$1"; shift; ' + code,
                           "test", str(SCRIPT), *map(str, args)],
                          check=True, capture_output=True, text=True,
                          stdin=subprocess.DEVNULL).stdout


class AssistedInstall(unittest.TestCase):
    def generate(self, password, password_hash=""):
        with tempfile.TemporaryDirectory() as folder:
            dest = Path(folder) / "generated"
            bash('AI_USERNAME=alice; AI_PASSWORD="$3"; AI_HASHED_PASSWORD="$4"; '
                 'generate_calamares_config "$1" "$2"', dest, CONFIG, password, password_hash)
            self.assertEqual(dest.stat().st_mode & 0o777, 0o700)
            keyboard = yaml.safe_load((dest / "modules/keyboard.conf").read_text())
            self.assertEqual(keyboard["XkbLayout"], "us")
            yaml.safe_load((dest / "modules/locale.conf").read_text())
            config = yaml.safe_load((dest / "modules/shellprocess.conf").read_text())
            self.assertEqual(config["i18n"]["name"], "Post-install configuration")
            return config["script"]

    def test_plain_password_is_a_command_and_preserves_content(self):
        commands = self.generate("secret!12")
        self.assertEqual(len(commands), 6)
        # Stub chpasswd so this never touches the host's user database.
        out = subprocess.check_output(["bash", "-c", 'chpasswd() { cat; }; ' +
                                       commands[-1]["command"]], text=True)
        self.assertEqual(out, "alice:secret!12\n")

    def test_hash_is_passed_literally_and_takes_precedence(self):
        password_hash = "$6$salt$abcdefghijklmnop"
        command = self.generate("ignored12", password_hash)[-1]["command"]
        out = subprocess.check_output(["bash", "-c",
            'usermod() { printf "%s\\n" "$@"; }; ' + command], text=True)
        self.assertEqual(out.splitlines(), ["-p", password_hash, "alice"])

    def test_no_password_keeps_existing_commands(self):
        self.assertEqual(len(self.generate("")), 5)

    def test_probe_tracks_and_releases_udisks_mount(self):
        with tempfile.TemporaryDirectory() as folder:
            Path(folder, "autoinstall.yaml").write_text("username: alice\n")
            out = bash('''
iso_autoinstall_dirs() { :; }
find_cidata_device() { printf /dev/fake; }
findmnt() { return 1; }
TEST_MOUNT="$1"
udisksctl() {
    if [[ "$1" == mount ]]; then printf 'Mounted /dev/fake at %s.\\n' "$TEST_MOUNT";
    else printf 'RELEASE:%s:%s\\n' "$2" "$3"; fi
}
probe_now
printf 'RECORDS:%s\\n' "${#CIDATA_UDISKS[@]}"
cleanup_cidata_mounts
printf 'REMAINING:%s\\n' "${#CIDATA_UDISKS[@]}"
''', folder)
            self.assertIn("RECORDS:1", out)
            self.assertIn("RELEASE:-b:/dev/fake", out)
            self.assertIn("REMAINING:0", out)

    def test_manual_mount_is_tracked_and_released(self):
        out = bash('''
findmnt() { return 1; }
udisksctl() { return 1; }
mkdir() { :; }
mountpoint() { return 1; }
mount() { :; }
umount() { printf 'UNMOUNT:%s\\n' "$1"; }
rmdir() { :; }
mount_device /dev/test-device
printf 'RECORDS:%s\\n' "${#CIDATA_MANUAL[@]}"
cleanup_cidata_mounts
printf 'REMAINING:%s\\n' "${#CIDATA_MANUAL[@]}"
''')
        self.assertIn("RECORDS:1", out)
        self.assertIn("UNMOUNT:/tmp/neos-cidata-test-device", out)
        self.assertIn("REMAINING:0", out)

    def test_reused_mount_is_not_unmounted(self):
        with tempfile.TemporaryDirectory() as folder:
            out = bash('TEST_MOUNT="$1"; findmnt() { printf "%s\\n" "$TEST_MOUNT"; }; '
                       'mount_device /dev/fake; '
                       'printf "%s:%s:%s" "$MOUNTED_CIDATA" "${#CIDATA_UDISKS[@]}" '
                       '"${#CIDATA_MANUAL[@]}"', folder)
            self.assertEqual(out, folder + ":0:0")


if __name__ == "__main__":
    unittest.main(verbosity=2)
