# Tooling validation architecture brief

- Keep `neosctl`'s public CLI and ranking output unchanged; exercise its existing parsing and concurrent HTTP paths through deterministic temporary files and local HTTP servers.
- Treat only active `Server =` directives as mirrors and retain the existing 15-entry ceiling.
- Extend the Rust auditor with a pure Calamares configuration check that maps declared module configuration files to the profile's local `modules/` directory.
- Make every failure identify the declaration and expected file so profile drift is actionable in CI.
- Unit tests use temporary profile roots, covering valid declarations, a missing module configuration, and the absence of declared configurations.
