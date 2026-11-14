#!/bin/bash
# The Calamares pacstrap job (neospacstrap) must turn pacman's output into
# moving progress. Without a TTY, pacman 6/7 print downloads as
# "<file> downloading..."; the module once matched only the older
# "downloading <file>..." form, counted nothing, and the bar sat near the
# start of the step for the whole download (uthsarad/NeOS#980). This feeds
# the real module pacman output in the shape the CI build logs show.
set -euo pipefail

cd "$(dirname "$0")/.."
MODULE="profile/airootfs/usr/lib/calamares/modules/neospacstrap/main.py"

if ! command -v python3 >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then echo "[FAIL] python3 required"; exit 1; fi
    echo "[WARN] python3 not installed — skipping."; exit 0
fi

echo "Verifying installer progress parsing..."
PYTHONDONTWRITEBYTECODE=1 python3 - "$MODULE" <<'PY'
import importlib.util, subprocess, sys, types

progress = []
lib = types.ModuleType("libcalamares")
lib.job = types.SimpleNamespace(setprogress=progress.append)
lib.utils = types.SimpleNamespace(debug=lambda *_: None, gettext_path=lambda: None,
                                  gettext_languages=lambda: None)
lib.globalstorage = types.SimpleNamespace(value=lambda key: "/tmp/target")
sys.modules["libcalamares"] = lib

packages = [f"pkg{i:03d}-1.{i}-1-x86_64" for i in range(400)]
lines = [":: Synchronizing package databases...", " core downloading...", " extra downloading...",
         "resolving dependencies...", "Packages (400) " + " ".join(packages), "",
         ":: Retrieving packages..."]
lines += [f" {p} downloading..." for p in packages]
lines += ["checking keyring...", "checking package integrity..."]
lines += [f"({i + 1}/400) installing {p.rsplit('-', 3)[0]}" for i, p in enumerate(packages)]
lines += ["==> applying NeOS overlay"]

class FakePopen:
    def __init__(self, *args, **kwargs):
        self.stdout = iter(line + "\n" for line in lines)
    def wait(self):
        return 0
    def kill(self):
        pass

spec = importlib.util.spec_from_file_location("neospacstrap", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.subprocess = types.SimpleNamespace(Popen=FakePopen, PIPE=subprocess.PIPE, STDOUT=subprocess.STDOUT)

failed = False
def check(ok, msg):
    global failed
    print(f"  [{'PASS' if ok else 'FAIL'}] {msg}")
    failed |= not ok

result = module.run()
check(result is None, "job succeeds")
check(progress == sorted(progress), "progress never goes backwards")
download = [p for p in progress if 0.05 <= p <= 0.45]
check(len(set(download)) > 300, f"download phase moves smoothly ({len(set(download))} distinct steps)")
check(any(0.2 < p < 0.4 for p in progress), "progress passes through the middle of the download phase")
check(max(p for p in progress if p < 0.97) >= 0.94, "install phase reaches ~95%")
check(progress[-1] == 1.0, "job ends at 100%")
check("Downloading pkg" in module.status or module.status == "Base system installed.", "status text is set")
sys.exit(1 if failed else 0)
PY
echo "[PASS] Installer progress parsing verified."
