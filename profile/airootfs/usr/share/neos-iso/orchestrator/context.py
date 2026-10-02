"""Install context: parsed configurator output, invocation paths, and a
mutable `state` dict for objects that live across phases (e.g., the
archinstall config handler and mirror list handler)."""

from __future__ import annotations

import copy
import json
import os
import secrets
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


@dataclass
class InstallContext:
    config_path: Path
    creds_path: Path
    full_name: str
    email: str
    encrypt: bool
    authorized_keys_path: Path | None
    tailscale_authkey_path: Path | None

    user_configuration: dict
    user_credentials: dict
    arch_config_path: Path
    neos_install: dict[str, Any]
    defer_provisioning: bool = False
    # Top-level archinstall config keys whose values are secrets (today only
    # `encryption_password`). They are never written to the state files below;
    # archinstall_adapter.load_arch_config injects them into archinstall's
    # parsed config in memory. repr=False keeps them out of tracebacks/logs.
    archinstall_secrets: dict[str, str] = field(default_factory=dict, repr=False)

    target: Path = Path("/mnt")
    neos_path: Path = Path("/usr/share/neos")
    state_dir: Path = Path("/run/neos-install")
    log_path: Path = Path("/var/log/neos-install.log")
    target_log_path: Path = Path("/mnt/var/log/neos-install.log")

    # Mutable per-run state shared across phases (e.g., 'arch_config_handler',
    # 'mirror_handler'). Phases populate as needed; later phases read.
    state: dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_env(cls) -> "InstallContext":
        config_str = os.environ.get("NEOS_INSTALL_CONFIG")
        creds_str = os.environ.get("NEOS_INSTALL_CREDS")
        if not config_str or not creds_str:
            raise RuntimeError("NEOS_INSTALL_CONFIG and NEOS_INSTALL_CREDS must be set")

        config_path = Path(config_str)
        creds_path = Path(creds_str)
        user_configuration = json.loads(config_path.read_text())
        neos_install = user_configuration.get("neos_install") or _default_neos_install(user_configuration)

        # Autoinstall configs may omit kernels, which makes archinstall default
        # to stock linux. Apply the same hardware default as the configurator,
        # while honoring an explicit selection (including storage-only configs).
        if not user_configuration.get("kernels"):
            kernel = (neos_install.get("storage") or {}).get("kernel") or _default_kernel()
            user_configuration["kernels"] = [kernel]

        # Deferred provisioning: the whole system installs but user creation is deferred to
        # first boot. Selected by the configurator (neos_install.defer_provisioning) or by
        # an `defer-provisioning` marker file on an autoinstall drive, which also replaces the
        # user_credentials.json requirement.
        defer_provisioning_marker = _optional_path(os.environ.get("NEOS_INSTALL_DEFER_PROVISIONING_FILE"))
        defer_provisioning = bool(neos_install.get("defer_provisioning")) or defer_provisioning_marker is not None
        neos_install["defer_provisioning"] = defer_provisioning

        if creds_path.exists():
            user_credentials = json.loads(creds_path.read_text())
        elif defer_provisioning:
            user_credentials = {"users": []}
        else:
            raise RuntimeError(f"credentials file missing: {creds_path}")

        if defer_provisioning:
            # Deferred provisioning promises no account until first boot. A supplied
            # credentials file (a rig handing over its LUKS passphrase) must
            # not smuggle in users or a root password.
            encryption_password = user_credentials.get("encryption_password")
            user_credentials = {"users": []}
            if encryption_password:
                user_credentials["encryption_password"] = encryption_password

        arch_configuration = dict(user_configuration)
        arch_configuration.pop("neos_install", None)

        if defer_provisioning:
            # The userless invariant covers the archinstall config too: a
            # combined/legacy config could carry account authentication that
            # archinstall would still act on (users, a root password). Strip
            # every such field so no account is created before first boot.
            _strip_account_fields(arch_configuration)

        state_dir = Path(os.environ.get("NEOS_INSTALL_STATE_DIR", "/run/neos-install"))
        state_dir.mkdir(mode=0o700, parents=True, exist_ok=True)

        # No secret is ever written to the state files. archinstall reads the
        # LUKS passphrase only from the top-level `encryption_password` key of
        # its merged --config/--creds input, and silently installs WITHOUT
        # encryption when that key is missing (DiskEncryption.parse_arg returns
        # None without a password), so the passphrase is carried in memory
        # (archinstall_secrets) and injected by archinstall_adapter instead.
        # The config is written before a provisioning passphrase is generated
        # below, so a generated one cannot end up in it either.
        arch_config_path = state_dir / "archinstall-user_configuration.json"
        write_private(arch_config_path, json.dumps(_without_encryption_password(arch_configuration), indent=2) + "\n")

        if defer_provisioning:
            # The credentials file archinstall reads in deferred mode is ours to
            # write. It carries no accounts (see above) and no secrets.
            creds_path = state_dir / "provisioning-user_credentials.json"
            write_private(creds_path, json.dumps({"users": []}, indent=2) + "\n")

            # Encrypted deferred-provisioning installs have no user password to protect LUKS
            # with. Generate a throwaway passphrase (staged for first-boot
            # re-key by the stage_provisioning_state phase, which reads it back
            # from the in-memory disk_encryption block).
            _inject_provisioning_encryption_password(user_configuration, user_credentials)

        archinstall_secrets: dict[str, str] = {}
        if encryption_password := _archinstall_encryption_password(user_configuration, user_credentials):
            archinstall_secrets["encryption_password"] = encryption_password

        ctx = cls(
            config_path=config_path,
            creds_path=creds_path,
            full_name=_read_text(os.environ.get("NEOS_INSTALL_FULL_NAME_FILE")),
            email=_read_text(os.environ.get("NEOS_INSTALL_EMAIL_FILE")),
            encrypt=_read_text(os.environ.get("NEOS_INSTALL_ENCRYPT_FILE")).lower() in ("true", "yes", "1"),
            authorized_keys_path=_optional_path(os.environ.get("NEOS_INSTALL_AUTHORIZED_KEYS_FILE")),
            tailscale_authkey_path=_optional_path(os.environ.get("NEOS_INSTALL_TAILSCALE_AUTHKEY_FILE")),
            user_configuration=user_configuration,
            user_credentials=user_credentials,
            arch_config_path=arch_config_path,
            neos_install=neos_install,
            defer_provisioning=defer_provisioning,
            archinstall_secrets=archinstall_secrets,
            state_dir=state_dir,
        )
        disk_config = user_configuration.get("disk_config", {})
        target_mount = neos_install.get("target_mount") or disk_config.get("mountpoint")
        if target_mount:
            ctx.target = Path(target_mount)
        return ctx

    @property
    def username(self) -> str:
        users = self.user_credentials.get("users") or []
        if users:
            return users[0]["username"]
        if self.defer_provisioning:
            return ""
        raise RuntimeError("user_credentials.json contains no users")

    @property
    def mode(self) -> str:
        if mode := self.neos_install.get("mode"):
            return mode
        cfg_type = self.user_configuration.get("disk_config", {}).get("config_type")
        return "protected" if cfg_type == "pre_mounted_config" else "full_disk"

    @property
    def is_protected(self) -> bool:
        return self.mode == "protected"


def _strip_account_fields(arch_configuration: dict) -> None:
    """Remove every field archinstall reads to create users or set a root
    password, so it cannot ship a hidden provisioning account.
    Encryption material lives elsewhere (disk_config.disk_encryption) and is
    untouched."""
    for key in ("!users", "!root-password", "root_enc_password", "users"):
        arch_configuration.pop(key, None)

    auth = arch_configuration.get("auth_config")
    if isinstance(auth, dict):
        for key in ("users", "root_enc_password"):
            auth.pop(key, None)


def _without_encryption_password(arch_configuration: dict) -> dict:
    """Copy of the archinstall config without the LUKS passphrase, for disk.

    Removes the top-level `encryption_password` (re-injected in memory from
    InstallContext.archinstall_secrets) and the nested
    disk_config.disk_encryption copy, which archinstall ignores and only the
    orchestrator reads, from memory."""
    config = copy.deepcopy(arch_configuration)
    config.pop("encryption_password", None)
    disk_encryption = (config.get("disk_config") or {}).get("disk_encryption")
    if isinstance(disk_encryption, dict):
        disk_encryption.pop("encryption_password", None)
    return config


def write_private(path: Path, text: str) -> None:
    """Write `text` to `path` readable by its owner only.

    The file is created 0600 (no write-then-chmod window in which it is
    world-readable); an existing file is replaced, not followed if it is a
    symlink."""
    path.unlink(missing_ok=True)
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as handle:
        handle.write(text)


def _archinstall_encryption_password(user_configuration: dict, user_credentials: dict) -> str | None:
    """The passphrase archinstall would have resolved from the files: the
    credentials file wins over the config file (archinstall merges --creds
    over --config); the nested disk_encryption copy is NeOS's own location."""
    disk_encryption = (user_configuration.get("disk_config") or {}).get("disk_encryption") or {}
    return (
        user_credentials.get("encryption_password")
        or user_configuration.get("encryption_password")
        or disk_encryption.get("encryption_password")
    )


def _inject_provisioning_encryption_password(user_configuration: dict, user_credentials: dict) -> None:
    """Ensure an encrypted deferred-provisioning install has a LUKS passphrase archinstall can
    use. Reuse one the input already carries (an autoinstall rig may supply
    its own); otherwise generate a throwaway. Mutates the in-memory
    disk_encryption block so the stage_provisioning_state phase can read the
    effective passphrase back; nothing here is written to disk."""
    disk_encryption = (user_configuration.get("disk_config") or {}).get("disk_encryption")
    if disk_encryption is None:
        return

    password = disk_encryption.get("encryption_password") or user_credentials.get("encryption_password")
    if not password:
        password = secrets.token_urlsafe(24)

    disk_encryption["encryption_password"] = password
    user_credentials["encryption_password"] = password


def _default_kernel(pci_devices: Path = Path("/sys/bus/pci/devices")) -> str:
    for device in pci_devices.glob("*"):
        try:
            vendor = (device / "vendor").read_text().strip().lower()
            device_id = (device / "device").read_text().strip().lower()
        except OSError:
            continue
        if vendor == "0x106b" and device_id in {"0x1801", "0x1802"}:
            return "linux-t2"
    return "linux-neos"


def _default_neos_install(user_configuration: dict) -> dict[str, Any]:
    disk_config = user_configuration.get("disk_config", {})
    mode = "protected" if disk_config.get("config_type") == "pre_mounted_config" else "full_disk"
    return {
        "mode": mode,
        "target_mount": disk_config.get("mountpoint") or "/mnt",
        "boot": {
            "esp_mount": "/boot",
            "esp_path": "/EFI/limine",
            "efi_binary": "limine_x64.efi",
            "enable_fallback": mode == "full_disk",
        },
        "storage": {},
    }


def _optional_path(path: str | None) -> Path | None:
    """A path the caller always passes but that need not exist. The live ISO
    passes --authorized-keys-file on every install; only autoinstall drives put
    a file there."""
    if not path:
        return None
    p = Path(path)
    return p if p.exists() else None


def _read_text(path: str | None) -> str:
    if not path:
        return ""
    p = Path(path)
    if not p.exists():
        return ""
    return p.read_text().strip()
