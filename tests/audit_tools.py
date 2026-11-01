"""Audit runner and merge-policy regression checks against fake subprocesses."""
import argparse
import importlib.util
import json
import os
import shutil
from pathlib import Path
import subprocess
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("audit", ROOT / "tools/audit.py")
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class AuditRunner(unittest.TestCase):
    def test_failures_timeouts_and_missing_coverage_are_reported(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "tests").mkdir()
            scripts = {"pass": "exit 0", "fail": "exit 7",
                       "missing": "echo '[WARN] tool missing'", "slow": "sleep 10",
                       "message": "echo '{\"skipped\":0}'"}
            for name, text in scripts.items():
                (root / "tests" / f"verify_{name}.sh").write_text(text)
            output = root / "reports"
            output.mkdir()
            args = argparse.Namespace(strict=False, only=None, include_ui=False, timeout=1)
            self.assertEqual(audit.run(root, args, output), 1)
            result = json.loads((output / "summary.json").read_text())["results"]
            statuses = {r["check"]: r["status"] for r in result}
            self.assertEqual(statuses, {"verify_pass.sh": "passed", "verify_fail.sh": "failed",
                                       "verify_missing.sh": "incomplete", "verify_slow.sh": "timeout",
                                       "verify_message.sh": "passed"})
            args.only = ["verify_missing.sh"]
            self.assertEqual(audit.run(root, args, output), 0)
            args.strict = True
            self.assertEqual(audit.run(root, args, output), 1)


class MergePolicy(unittest.TestCase):
    def execute(self, state, fork=False, stale=False):
        config = yaml.safe_load((ROOT / ".github/workflows/jules-auto-merge.yml").read_text())
        script = config["jobs"]["merge-into-testing"]["steps"][0]["run"]
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            calls = root / "calls"
            gh = root / "gh"
            gh.write_text('''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
with open(os.environ['CALLS'], 'a') as f: f.write(json.dumps(args) + '\\n')
if args[:2] == ['pr', 'view']:
 print(json.dumps(dict(state='OPEN',baseRefName='testing',headRefName='fix',isDraft=False,
  isCrossRepository=os.environ['FORK']=='1',author={'login':'tester'},url='https://example.invalid/pr/1',
  changedFiles=1,headRefOid='validated-head')))
elif args[:2] == ['pr', 'checks']:
 print(json.dumps([dict(name='test',state=os.environ['CHECK_STATE']),
                   dict(name='merge-into-testing',state='IN_PROGRESS')]))
elif args[:2] == ['pr', 'merge'] and os.environ['STALE']=='1':
 sys.exit(1)
''')
            gh.chmod(0o755)
            env = dict(os.environ, PATH=str(root) + ":" + os.environ["PATH"],
                       CALLS=str(calls), CHECK_STATE=state, FORK=str(int(fork)), STALE=str(int(stale)),
                       PR_URL="https://example.invalid/pr/1", EVENT_NAME="pull_request_target",
                       EVENT_ACTION="synchronize")
            result = subprocess.run(["bash", "-c", script], env=env,
                                    stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=10)
            return result.returncode, [json.loads(line) for line in calls.read_text().splitlines()]

    def test_success_merges_exact_head_without_waiting_for_itself(self):
        code, calls = self.execute("SUCCESS")
        self.assertEqual(code, 0)
        merge = next(c for c in calls if c[:2] == ["pr", "merge"])
        self.assertIn("--match-head-commit", merge)
        self.assertEqual(merge[merge.index("--match-head-commit") + 1], "validated-head")
        self.assertNotIn("--admin", merge)

    def test_failed_ci_never_merges(self):
        code, calls = self.execute("FAILURE")
        self.assertNotEqual(code, 0)
        self.assertFalse(any(c[:2] == ["pr", "merge"] for c in calls))

    def test_fork_never_merges_automatically(self):
        code, calls = self.execute("SUCCESS", fork=True)
        self.assertEqual(code, 0)
        self.assertFalse(any(c[:2] == ["pr", "merge"] for c in calls))

    def test_stale_head_does_not_retry_without_pin(self):
        code, calls = self.execute("SUCCESS", stale=True)
        self.assertNotEqual(code, 0)
        self.assertEqual(sum(c[:2] == ["pr", "merge"] for c in calls), 1)


class WorkflowScan(unittest.TestCase):
    def scan(self, unsafe):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / "tests").mkdir()
            (root / ".github/workflows").mkdir(parents=True)
            gate = root / "tests/verify_workflow_security.sh"
            shutil.copyfile(ROOT / "tests/verify_workflow_security.sh", gate)
            run = 'echo "${{ github.event.pull_request.title }}"' if unsafe else 'echo "$TITLE"'
            (root / ".github/workflows/check.yml").write_text(
                "name: Check\non: pull_request\njobs:\n  test:\n    runs-on: ubuntu-latest\n"
                "    steps:\n      - env:\n          TITLE: ${{ github.event.pull_request.title }}\n"
                "        run: " + run + "\n")
            return subprocess.run(["bash", str(gate)], capture_output=True, text=True,
                                  stdin=subprocess.DEVNULL, timeout=15)

    def test_untrusted_run_expression_is_rejected(self):
        result = self.scan(True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("expands untrusted input", result.stdout)

    def test_environment_boundary_is_accepted(self):
        result = self.scan(False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
