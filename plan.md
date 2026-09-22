## Implementation Plan

1. **Phase 1: Scope Validation**
   - Confirm tasks match `ARCHITECT_SCOPE.json`: `build.sh` and `profile/airootfs/usr/local/bin/neos-autoupdate.sh` are explicitly allowed.
   - Refuse feature expansion.

2. **Phase 2: Impact Mapping**
   - Modified files: `build.sh` (optimization of packaging pipeline), `ai/tasks/bolt.json`, `ai/tasks/palette.json`, `ai/tasks/sentinel.json`, `ARCHITECT_REPORT.md`
   - Test scripts to run: `tests/verify_build_profile.sh`, `tests/verify_autoupdate_security.sh`

3. **Phase 3: Implementation Plan**
   - In `build.sh`, add Bolt optimization annotations.
   - Update `build.sh` with a fix for subprocess overhead. For instance, the section with:
     ```bash
     has_pkgs=0
     shopt -s nullglob
     for _ in "$INSTALL_REPO"/*.pkg.tar.zst; do
         has_pkgs=1
         break
     done
     shopt -u nullglob
     ```
     is already optimized to avoid subshell overhead compared to `ls`. The find/sort/head/cut pipeline is also already optimized to bash globbing (`-nt`). I will add delegation comments in `build.sh` around any other subprocesses where needed, but since it's already optimized, I will just add the required comments. Wait, `build.sh` has a task for Bolt: "Optimize subprocess overhead in build.sh packaging and compression pipelines".
     Since I am the Architect, I will only implement the smallest correct baseline or coordinate. In `build.sh`, I'll mark the pipeline for Bolt to optimize. Specifically, the `xorriso` compression/packaging pipeline:
     ```bash
     # Bolt: [Performance] Optimize this xorriso execution and pipeline to reduce subprocess overhead during ISO packaging.
     ```

4. **Phase 4: Build**
   - Add comments in `build.sh` marking potential optimization areas for Bolt.
   - Add comments in `profile/airootfs/usr/local/bin/neos-autoupdate.sh` for Sentinel (security audit).
   - Write tests: Ensure `tests/verify_build_profile.sh` passes.

5. **Phase 5: Delegation Preparation**
   - Generate/update task manifests for Bolt, Palette, and Sentinel.
   - Update `ARCHITECT_REPORT.md`.

6. **Complete pre-commit steps**
   - Execute `tests/verify_build_profile.sh`.
   - Execute `tests/verify_autoupdate_security.sh`.
