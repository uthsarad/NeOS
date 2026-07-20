# Sentinel Report

### Risks found
- **CWE-59 (Symlink Traversal) in `neos-liveuser-setup`**: The script created directories (`.config/autostart`, `Desktop`) and wrote to files (`kwinrc`, `kdeglobals`) inside `/home/liveuser` without verifying if these target paths were symlinks. This could allow an attacker to overwrite arbitrary system files if they pre-created symlinks in the live user's home directory.
- **Insufficient Sandboxing in `neos-liveuser-setup.service`**: While core sandboxing was omitted correctly to allow `useradd`, additional safe restrictions like `ProtectKernelModules` and `MemoryDenyWriteExecute` were missing. `neos-autoupdate.service` sandboxing and `ReadWritePaths` were audited and found to be minimal and secure.

### Fixes applied
- Added `[[ -L ]]` checks for subdirectories in `neos-liveuser-setup` before creation.
- Added `rm -f` before writing to config files in `neos-liveuser-setup` to break any existing symlinks.
- Ensured `chmod +x` is only applied if the target is not a symlink.
- Added `ProtectKernelModules=yes`, `MemoryDenyWriteExecute=yes`, and `RestrictNamespaces=yes` to `neos-liveuser-setup.service`.

### Remaining attack surface
- The live user environment is inherently open and runs with passwordless `sudo` by design, which represents a persistent elevated privilege surface. The `neos-liveuser-setup.service` requires elevated capabilities and cannot be fully sandboxed (e.g., using `ProtectSystem=strict` or `NoNewPrivileges=yes`) due to its function of creating the live user and configuring the graphical environment.

### Severity summary
- **Symlink Traversal**: HIGH severity. Mitigated.
- **Systemd Sandboxing**: LOW severity (defense in depth). Mitigated.
