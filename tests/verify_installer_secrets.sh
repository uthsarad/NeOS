#!/bin/bash
# The install orchestrator (profile/airootfs/usr/share/neos-iso/orchestrator)
# must never write a disk-encryption passphrase to its state files, and must
# still hand that passphrase to archinstall — archinstall installs WITHOUT
# encryption when it cannot find one (DiskEncryption.parse_arg returns None).
# A CodeQL autofix once traded the second property for the first; this guards
# both (reports/v2026.10.02/00-improvement-plan.md A1).
set -euo pipefail

cd "$(dirname "$0")/.."
ORCH_PARENT="profile/airootfs/usr/share/neos-iso"

if ! command -v python3 >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] python3 is required (REQUIRE_TOOLS=1)"
        exit 1
    fi
    echo "[WARN] python3 not installed — skipping."
    exit 0
fi

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

echo "Verifying installer secret handling..."

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$SANDBOX/stub:$ORCH_PARENT" python3 - "$SANDBOX" <<'PY'
import json
import os
import stat
import sys
import types
from pathlib import Path

sandbox = Path(sys.argv[1])
failed = False


def check(ok: bool, message: str) -> None:
    global failed
    print(f"  [{'PASS' if ok else 'FAIL'}] {message}")
    failed |= not ok


# --- stub archinstall: only what archinstall_adapter imports, plus the real
# parsing contract of ArchConfigHandler (argv -> _parse_config -> from_config,
# all inside __init__; --creds merged over --config).
class ArchConfigHandler:
    def __init__(self):
        argv = sys.argv
        self._args = {argv[i]: argv[i + 1] for i in range(1, len(argv) - 1, 2)}
        self._config = self._parse_config()

    def _parse_config(self):
        config = json.loads(Path(self._args["--config"]).read_text())
        config.update(json.loads(Path(self._args["--creds"]).read_text()))
        return config

    @property
    def config(self):
        return self._config


def _module(name, **attrs):
    module = types.ModuleType(name)
    module.__dict__.update(attrs)
    sys.modules[name] = module
    return module


placeholder = type("Placeholder", (), {})
for name in [
    "archinstall", "archinstall.lib", "archinstall.lib.authentication",
    "archinstall.lib.disk", "archinstall.lib.mirror", "archinstall.lib.models",
]:
    _module(name)
_module("archinstall.lib.args", ArchConfig=placeholder, ArchConfigHandler=ArchConfigHandler)
_module("archinstall.lib.authentication.authentication_handler", AuthenticationHandler=placeholder)
_module("archinstall.lib.disk.filesystem", FilesystemHandler=placeholder)
_module("archinstall.lib.disk.utils", get_parent_device_path=None, get_unique_path_for_device=None, udev_sync=None)
_module("archinstall.lib.hardware", SysInfo=placeholder)
_module("archinstall.lib.installer", Installer=placeholder)
_module("archinstall.lib.mirror.mirror_handler", MirrorListHandler=placeholder)
_module("archinstall.lib.models", Bootloader=placeholder)
_module("archinstall.lib.models.device", DiskLayoutType=placeholder, EncryptionType=placeholder)
_module("archinstall.lib.models.users", User=placeholder)

from orchestrator import archinstall_adapter
from orchestrator.context import InstallContext


def run_case(name, user_configuration, creds=None, defer=False):
    case = sandbox / name
    case.mkdir()
    config_path = case / "user_configuration.json"
    config_path.write_text(json.dumps(user_configuration))
    creds_path = case / "user_credentials.json"
    if creds is not None:
        creds_path.write_text(json.dumps(creds))
    env = {
        "NEOS_INSTALL_CONFIG": str(config_path),
        "NEOS_INSTALL_CREDS": str(creds_path),
        "NEOS_INSTALL_STATE_DIR": str(case / "state"),
    }
    if defer:
        marker = case / "defer-provisioning"
        marker.touch()
        env["NEOS_INSTALL_DEFER_PROVISIONING_FILE"] = str(marker)
    saved = dict(os.environ)
    os.environ.update(env)
    try:
        ctx = InstallContext.from_env()
    finally:
        os.environ.clear()
        os.environ.update(saved)
    return ctx, case / "state"


def assert_state_clean(state_dir, secret, label):
    files = sorted(p for p in state_dir.iterdir() if p.is_file())
    check(bool(files), f"{label}: state files written")
    for path in files:
        mode = stat.S_IMODE(path.stat().st_mode)
        check(mode == 0o600, f"{label}: {path.name} is 0600 (got {oct(mode)})")
        check(secret not in path.read_text(), f"{label}: {path.name} does not contain the passphrase")


disk_config = {
    "config_type": "default_layout",
    "device_modifications": [{"device": "/dev/vda", "wipe": True, "partitions": []}],
    "disk_encryption": {"encryption_type": "luks", "partitions": ["root"]},
}

# 1. Deferred provisioning, generated passphrase.
ctx, state = run_case("deferred-generated", {"disk_config": json.loads(json.dumps(disk_config))}, defer=True)
generated = ctx.archinstall_secrets.get("encryption_password", "")
check(len(generated) >= 24, "deferred: a provisioning passphrase was generated")
check(
    ctx.user_configuration["disk_config"]["disk_encryption"].get("encryption_password") == generated,
    "deferred: passphrase is readable in memory for stage_provisioning_state",
)
assert_state_clean(state, generated, "deferred")
handler = archinstall_adapter.load_arch_config(ctx.arch_config_path, ctx.creds_path, ctx.archinstall_secrets)
check(handler.config.get("encryption_password") == generated, "deferred: archinstall receives the passphrase")
check(handler.config.get("users") == [], "deferred: archinstall receives no accounts")
check("archinstall_secrets" not in repr(ctx), "deferred: secrets are kept out of repr()")

# 2. Deferred provisioning, rig-supplied passphrase plus smuggled accounts.
rig_secret = "rig-supplied-luks-passphrase"
ctx, state = run_case(
    "deferred-rig",
    {"disk_config": json.loads(json.dumps(disk_config)), "!root-password": "nope"},
    creds={"encryption_password": rig_secret, "users": [{"username": "x", "!password": "y"}]},
    defer=True,
)
assert_state_clean(state, rig_secret, "deferred+rig")
handler = archinstall_adapter.load_arch_config(ctx.arch_config_path, ctx.creds_path, ctx.archinstall_secrets)
check(handler.config.get("encryption_password") == rig_secret, "deferred+rig: archinstall receives the rig passphrase")
check(handler.config.get("users") == [] and "!root-password" not in handler.config, "deferred+rig: no accounts reach archinstall")

# 3. Normal install: the user's own credentials file is used unchanged.
user_secret = "users-own-luks-passphrase"
ctx, state = run_case(
    "normal",
    {"disk_config": json.loads(json.dumps(disk_config))},
    creds={"encryption_password": user_secret, "users": [{"username": "ada"}]},
)
assert_state_clean(state, user_secret, "normal")
check(ctx.creds_path.parent != state, "normal: the user's credentials file is passed through, not rewritten")
handler = archinstall_adapter.load_arch_config(ctx.arch_config_path, ctx.creds_path, ctx.archinstall_secrets)
check(handler.config.get("encryption_password") == user_secret, "normal: archinstall receives the passphrase")

sys.exit(1 if failed else 0)
PY

echo "[PASS] Installer secret handling verified."
