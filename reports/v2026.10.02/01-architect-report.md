# 2026.10.02 — Architecture brief (inline, Smart Routing → Full-Gates)

Full-Gates, because the change touches `.github/workflows/`, credential handling, `VERSION`
and `CHANGELOG.md`. No new modules and no interface changes beyond the ones below.

- **Installer secrets (A1):** the only contract change. `archinstall_adapter.load_arch_config`
  gains an optional `secrets` argument (backwards compatible), and `InstallContext` gains
  `archinstall_secrets` (`repr=False`). Secrets are injected through an `ArchConfigHandler`
  subclass overriding `_parse_config`. That couples to one archinstall private method, so
  it lives in the adapter, the module that exists to contain archinstall API churn, and the
  coupling is pinned by `tests/verify_installer_secrets.sh` (stub that mirrors archinstall 4.5).
- **Auto-merge (A2):** behaviour change approved by the user on 2026-10-02 (same-repository
  PRs only; `workflow_dispatch` stays the explicit maintainer path).
- **Live services (A4):** deletion only. NetworkManager stays the single network owner;
  `neos-accessibility.service` stays the single owner of `accessibility=on`.
- **Hygiene (B, C):** no behaviour change, except that a new user's bash no longer errors on
  start. Manifests are regenerated with `tools/gen-manifests.sh` and the drift gate passes.
- **Out of scope:** keep or remove the dormant Omarchy components. That is a product
  decision, recorded in `docs/architecture/OMARCHY_INTEGRATION.md`.
