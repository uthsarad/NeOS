#!/bin/bash
# GitHub Actions hygiene for the workflows that hold release credentials
# (reports/v2026.10.02/00-improvement-plan.md A3/C6):
#   - attacker-controlled event fields (branch names, PR/issue titles and
#     bodies, commit messages) are never expanded with ${{ }} inside a `run:`
#     script, where they would execute as shell; they go through `env:`;
#   - actionlint passes when it is installed (it is not packaged for Arch, so
#     CI runs the static check above and actionlint stays a local extra).
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Verifying GitHub Actions workflow security..."

FAIL=0
UNTRUSTED='github\.head_ref|github\.event\.(pull_request|issue|comment|review|review_comment|discussion|head_commit|commits|pages)\.[A-Za-z_.]*(title|body|ref|label|message|name|email|page_name)'

for wf in .github/workflows/*.yml; do
    # Print each line of every `run:` block (block scalars included) with its
    # line number, then look for untrusted ${{ }} expansions in them.
    hits="$(awk -v pat="\\$\\{\\{[^}]*(${UNTRUSTED})[^}]*\\}\\}" '
        function indent(s) { match(s, /^ */); return RLENGTH }
        in_run && (indent($0) > run_indent || $0 ~ /^[[:space:]]*$/) {
            if ($0 ~ pat) printf "%d:%s\n", NR, $0
            next
        }
        { in_run = 0 }
        /^[[:space:]]*(- )?run:/ {
            if ($0 ~ pat) printf "%d:%s\n", NR, $0
            if ($0 ~ /run:[[:space:]]*[|>]/) { in_run = 1; run_indent = indent($0) }
        }
    ' "$wf")"
    if [[ -n "$hits" ]]; then
        echo "[FAIL] $wf expands untrusted input inside a run: script (pass it via env: instead):"
        while IFS= read -r hit; do echo "         $hit"; done <<< "$hits"
        FAIL=1
    else
        echo "  [PASS] $wf: no untrusted \${{ }} expansion in run: scripts"
    fi
done

if command -v actionlint >/dev/null 2>&1; then
    if actionlint; then
        echo "  [PASS] actionlint"
    else
        echo "[FAIL] actionlint reported findings"
        FAIL=1
    fi
else
    echo "  [INFO] actionlint not installed — static check only (go install github.com/rhysd/actionlint/cmd/actionlint@latest)"
fi

if (( FAIL )); then
    echo "[FAIL] Workflow security verification failed."
    exit 1
fi
echo "[PASS] Workflow security verified."
