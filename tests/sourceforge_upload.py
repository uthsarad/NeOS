"""SourceForge upload regressions; no network or real credentials are used."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]


class SourceForgeUpload(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        workflow = yaml.safe_load((ROOT / ".github/workflows/build-iso.yml").read_text())
        steps = [step for job in workflow["jobs"].values() for step in job.get("steps", [])]
        cls.script = next(step["run"] for step in steps
                          if step.get("name") == "Upload Release Assets to SourceForge")
        # Also verify the build job itself stays read-only on PRs.
        cls.build_permissions = workflow["jobs"]["build"].get("permissions", {})
        with tempfile.TemporaryDirectory() as folder:
            key = Path(folder) / "identity"
            subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(key)],
                           check=True, stdin=subprocess.DEVNULL)
            cls.key = key.read_text()

    def execute(self, success_on=1, key=None, known_hosts=""):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            binary = root / "bin"
            binary.mkdir()
            home = root / "home"
            (home / ".ssh").mkdir(parents=True)
            existing = home / ".ssh/id_rsa"
            existing.write_text("existing identity")
            (root / "out").mkdir()
            for name in ("neos.iso", "neos.torrent", "SHA256SUMS", "SHA512SUMS"):
                (root / "out" / name).write_text("fixture")
            (root / "release-body.md").write_text("release notes")
            (binary / "rsync").write_text('''#!/usr/bin/env python3
import json, os, shlex, stat, sys
from pathlib import Path
log = Path(os.environ['TEST_CALLS'])
calls = json.loads(log.read_text()) if log.exists() else []
args = sys.argv[1:]
ssh = shlex.split(args[args.index('-e')+1])
key = Path(ssh[ssh.index('-i')+1])
kh = Path(next(opt.split('=', 1)[1] for opt in ssh if opt.startswith('UserKnownHostsFile=')))
calls.append(dict(args=args, key=str(key), mode=stat.S_IMODE(key.stat().st_mode),
                  directory_mode=stat.S_IMODE(key.parent.stat().st_mode),
                  known_hosts=kh.read_text() if kh.exists() else '',
                  crlf=b'\\r' in key.read_bytes()))
log.write_text(json.dumps(calls))
if len(calls) < int(os.environ['TEST_SUCCESS_ON']):
 print('simulated connection failure', file=sys.stderr)
 sys.exit(255)
''')
            (binary / "ssh-keyscan").write_text("#!/bin/sh\necho unexpected-scan >&2\nexit 1\n")
            (binary / "sleep").write_text("#!/bin/sh\nexit 0\n")
            for path in binary.iterdir():
                path.chmod(0o755)
            env = dict(os.environ, PATH=str(binary) + ":" + os.environ["PATH"], HOME=str(home),
                       GITHUB_WORKSPACE=str(root), RELEASE_BRANCH="testing", RELEASE_VERSION="fixture",
                       SOURCEFORGE_USERNAME="test-user", SOURCEFORGE_PROJECT="test-project",
                       SOURCEFORGE_PRIVATE_KEY=self.key if key is None else key,
                       SOURCEFORGE_KNOWN_HOSTS=known_hosts,
                       TEST_CALLS=str(root / "calls.json"), TEST_SUCCESS_ON=str(success_on))
            result = subprocess.run(["bash", "-c", self.script], env=env,
                                    capture_output=True, text=True, timeout=15,
                                    stdin=subprocess.DEVNULL)
            log = root / "calls.json"
            calls = json.loads(log.read_text()) if log.exists() else []
            self.assertEqual(existing.read_text(), "existing identity")
            self.assertNotIn("unexpected-scan", result.stderr)
            self.assertNotIn(self.key.strip(), result.stdout + result.stderr)
            for call in calls:
                self.assertFalse(Path(call["key"]).exists(), "temporary identity was not removed")
            return result, calls

    def test_build_job_has_read_only_permissions(self):
        self.assertEqual(self.build_permissions, {"contents": "read"})

    def test_pinned_known_hosts_enforces_strict_host_key_checking(self):
        pinned = "frs.sourceforge.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeTestKeyMaterialOnly"
        result, calls = self.execute(known_hosts=pinned)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(calls), 1)
        command = calls[0]["args"][calls[0]["args"].index("-e") + 1]
        self.assertIn("StrictHostKeyChecking=yes", command)
        self.assertIn("frs.sourceforge.net", calls[0]["known_hosts"])

    def test_upload_does_not_depend_on_host_key_scan(self):
        result, calls = self.execute()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(calls), 1)
        self.assertEqual(calls[0]["mode"], 0o600)
        self.assertEqual(calls[0]["directory_mode"], 0o700)
        command = calls[0]["args"][calls[0]["args"].index("-e") + 1]
        self.assertIn("StrictHostKeyChecking=accept-new", command)
        self.assertIn("BatchMode=yes", command)
        self.assertIn("ConnectTimeout=20", command)

    def test_crlf_secret_and_retry(self):
        result, calls = self.execute(success_on=2, key=self.key.replace("\n", "\r\n"))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(len(calls), 2)
        self.assertFalse(calls[0]["crlf"])

    def test_exhausted_retries_fail_and_keep_diagnostics(self):
        result, calls = self.execute(success_on=99)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 3)
        self.assertIn("simulated connection failure", result.stderr)
        self.assertIn("Failed to upload assets after 3 attempts", result.stdout)

    def test_invalid_key_is_actionable_and_never_uploaded(self):
        result, calls = self.execute(key="not-a-private-key")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(calls)
        self.assertIn("valid, unencrypted OpenSSH private key", result.stdout)

    def test_missing_secret_skips_without_attempting_upload(self):
        result, calls = self.execute(key="")
        self.assertEqual(result.returncode, 0)
        self.assertFalse(calls)
        self.assertIn("Skipping upload", result.stdout)


if __name__ == "__main__":
    unittest.main(verbosity=2)
