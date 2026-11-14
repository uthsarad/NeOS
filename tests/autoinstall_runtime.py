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
    def generate(self, password, password_hash="", fullname="", locale_val="en_US.UTF-8", timezone=""):
        with tempfile.TemporaryDirectory() as folder:
            dest = Path(folder) / "generated"
            bash('AI_USERNAME=alice; AI_PASSWORD="$3"; AI_HASHED_PASSWORD="$4"; '
                 'AI_FULLNAME="$5"; AI_LOCALE="$6"; AI_TIMEZONE="$7"; '
                 'generate_calamares_config "$1" "$2"',
                 dest, CONFIG, password, password_hash, fullname, locale_val, timezone)
            self.assertEqual(dest.stat().st_mode & 0o777, 0o700)
            keyboard = yaml.safe_load((dest / "modules/keyboard.conf").read_text())
            self.assertEqual(keyboard["XkbLayout"], "us")
            locale_cfg = yaml.safe_load((dest / "modules/locale.conf").read_text())
            users_cfg = yaml.safe_load((dest / "modules/users.conf").read_text())
            raw_sp = (dest / "modules/shellprocess.conf").read_text()
            config = yaml.safe_load(raw_sp)
            self.assertEqual(config["i18n"]["name"], "Post-install configuration")
            return config["script"], raw_sp, users_cfg, locale_cfg

    def test_plain_password_is_hashed_and_never_stored_in_cleartext(self):
        base_scripts, _, _, _ = self.generate("")
        commands, raw_sp, _, _ = self.generate("secret!12")
        self.assertEqual(len(commands), len(base_scripts) + 1)
        self.assertNotIn("secret!12", raw_sp)
        cmd = commands[-1]["command"]
        self.assertIsInstance(cmd, list)
        self.assertEqual(cmd[:2], ["usermod", "-p"])
        self.assertEqual(cmd[3], "alice")
        generated_hash = cmd[2]
        self.assertTrue(generated_hash.startswith("$6$"), generated_hash)
        salt = generated_hash.split("$")[2]
        expected = subprocess.check_output(
            ["openssl", "passwd", "-6", "-salt", salt, "-stdin"],
            input="secret!12", text=True
        ).strip()
        self.assertEqual(generated_hash, expected)

    def test_hash_is_passed_literally_and_takes_precedence(self):
        password_hash = "$6$salt$abcdefghijklmnop"
        commands, raw_sp, _, _ = self.generate("ignored12", password_hash)
        self.assertNotIn("ignored12", raw_sp)
        command = commands[-1]["command"]
        self.assertIsInstance(command, list)
        self.assertEqual(command, ["usermod", "-p", password_hash, "alice"])

    def test_fullname_and_locale_timezone_serialized_safely(self):
        _, _, users_cfg, locale_cfg = self.generate(
            "", fullname='Alice "Ops": injected', locale_val="en_GB", timezone="Asia/Colombo"
        )
        self.assertEqual(users_cfg["presets"]["fullName"]["value"], 'Alice "Ops": injected')
        self.assertEqual(locale_cfg["localeConfiguration"]["LANG"], "en_GB.UTF-8")
        self.assertEqual(locale_cfg["region"], "Asia")
        self.assertEqual(locale_cfg["zone"], "Colombo")

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
