1. **Create the `docs/decisions/` directory**
   - Execute `mkdir -p docs/decisions` to fulfill the instruction from `ARCHITECT_SCOPE.json`.

2. **Create the new file `docs/decisions/0001-core-architecture-decisions.md`**
   - Write the contents of the architecture decision document consolidating the reasons for using linux-lts, Btrfs + snapper, Calamares installer, plasma-meta, and 8 parallel downloads.
   - I will use `run_in_bash_session` to run:
     ```bash
     cat << 'EOF' > docs/decisions/0001-core-architecture-decisions.md
     # 0001: Core Architecture Decisions

     ## 1. linux-lts vs linux-zen
     We use `linux-lts` to prioritize system stability and predictability.
     <!-- @Bolt: Monitor this documentation addition to ensure no unnecessary heavy assets are included that might bloat the repository. -->

     ## 2. Btrfs + snapper
     Btrfs and snapper are chosen to enable snapshot-based rollbacks, ensuring a stable upgrade cycle.

     ## 3. Calamares installer
     Calamares is selected for its robust, GUI-driven installer experience that aligns with our goal of a Windows-familiar onboarding process.
     <!-- @Palette: Ensure the markdown structure of this ADR is scannable, accessible, and uses clear heading hierarchies. -->

     ## 4. plasma-meta
     `plasma-meta` provides a comprehensive KDE Plasma desktop environment out of the box, offering a curated experience.

     ## 5. 8 parallel downloads
     We enable 8 parallel downloads in pacman to improve installation and update speeds without overwhelming package mirrors.
     <!-- @Sentinel: Verify no sensitive operational details or credentials are leaked in this documentation. -->
     EOF
     ```

3. **Update `README.md` to include a link to the new ADR**
   - Read the content of `README.md` and use `run_in_bash_session` with python to add the link `[Architecture Decision Records](docs/decisions/0001-core-architecture-decisions.md)` under the Documentation section:
     ```bash
     cat << 'EOF' > update_readme.py
     import re
     with open('README.md', 'r') as f:
         content = f.read()
     pattern = r'(## Documentation\n(?:-[^\n]+\n)*)'
     replacement = r'\1- **[Architecture Decision Records](docs/decisions/0001-core-architecture-decisions.md)** - Log of major architecture decisions.\n'
     new_content = re.sub(pattern, replacement, content)
     with open('README.md', 'w') as f:
         f.write(new_content)
     EOF
     python3 update_readme.py
     rm update_readme.py
     ```

4. **Append new tasks to the specialist JSON manifests**
   - Use a python script via `run_in_bash_session` to load and append the required tasks into `ai/tasks/bolt.json`, `ai/tasks/palette.json`, and `ai/tasks/sentinel.json`:
     ```bash
     cat << 'EOF' > append_tasks.py
     import json
     import os

     def append_task(file_path, task):
         with open(file_path, 'r') as f:
             data = json.load(f)
         data['tasks'].append(task)
         with open(file_path, 'w') as f:
             json.dump(data, f, indent=2, ensure_ascii=False)

     append_task('ai/tasks/bolt.json', {
         "description": "Monitor documentation updates to ensure no heavy assets (images, unoptimized diagrams) are added that could bloat the repository size.",
         "target_file": "docs/decisions/0001-core-architecture-decisions.md"
     })
     append_task('ai/tasks/palette.json', {
         "description": "Ensure the markdown structure of the new ADR is scannable, accessible, and uses clear heading hierarchies for easy reading.",
         "target_file": "docs/decisions/0001-core-architecture-decisions.md"
     })
     append_task('ai/tasks/sentinel.json', {
         "description": "Verify that no sensitive operational details, credentials, or internal infrastructure information are leaked in the newly created architecture decisions documentation.",
         "target_file": "docs/decisions/0001-core-architecture-decisions.md"
     })
     EOF
     python3 append_tasks.py
     rm append_tasks.py
     ```

5. **Append to `ARCHITECT_REPORT.md`**
   - Document the completed steps and how constraints were adhered to by appending to `ARCHITECT_REPORT.md` via `run_in_bash_session`:
     ```bash
     cat << 'EOF' >> ARCHITECT_REPORT.md

     ## Architect Report - Architecture Decision Records Implementation

     ## Objective
     Implement the initial Architecture Decision Record (ADR) consolidating major architectural choices and link it in the README, as mandated by the `ARCHITECT_SCOPE.json` and `STRATEGIC_DIRECTIVE.md`.

     ## Actions Taken
     1. **Scope Validation**: Confirmed the task fits within `ARCHITECT_SCOPE.json`, targeting only the creation of `docs/decisions/0001-core-architecture-decisions.md` and modifying `README.md`.
     2. **Implementation**: Created the new ADR document explaining `linux-lts`, Btrfs + snapper, Calamares, `plasma-meta`, and 8 parallel downloads. Added a link to this ADR in `README.md`.
     3. **Delegation**: Added clear inline comments for Bolt (performance), Palette (UX/accessibility), and Sentinel (security) in the new ADR file. Appended the required tasks to `ai/tasks/bolt.json`, `ai/tasks/palette.json`, and `ai/tasks/sentinel.json` safely using a Python JSON parser.

     ## Constraints Adhered To
     - The surface area was strictly limited to creating the new ADR document and updating the `README.md`.
     - Made NO modifications to any executable code, configuration files, or CI workflows.
     - Preserved existing specialist tracking data by using JSON parsing to securely append new tasks.
     EOF
     ```

6. **Verify the documents are created correctly**
   - Use `ls -l docs/decisions` to confirm `0001-core-architecture-decisions.md` exists.
   - Use `cat docs/decisions/0001-core-architecture-decisions.md` to verify the content.
   - Use `tail -n 15 README.md` to ensure the ADR link is correctly placed.
   - Use `tail -n 5 ai/tasks/bolt.json`, `tail -n 5 ai/tasks/palette.json`, `tail -n 5 ai/tasks/sentinel.json` to verify tasks were added.
   - Use `tail -n 20 ARCHITECT_REPORT.md` to verify report additions.

7. **Run relevant tests**
   - Execute all non-ISO validation scripts to verify no regressions were introduced.
   - Run `for test in tests/verify_*.sh; do if [[ $test != tests/verify_iso_*.sh ]]; then bash "$test"; fi; done` via `run_in_bash_session`.

8. **Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done.**
   - Run the pre commit instructions tool to retrieve final steps.

9. **Request code review**
   - Request a code review using `request_code_review` with branch `feat/adr-0001`, title `docs: Implement Architecture Decision Records (ADRs)`, and description `Creates the initial ADR for core architectural decisions, updates the README.md, and updates the task delegations.`.
