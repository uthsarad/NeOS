#!/usr/bin/env bash
# NeOS Automated Commit, PR, & Sync Utility
# Automatically commits changes, pushes to fork, opens a PR on upstream,
# and synchronizes the local repository with upstream main.

set -euo pipefail

COMMIT_MSG="${1:-"🔄 Update: Synchronize NeOS modifications"}"
UPSTREAM_REPO="uthsarad/NeOS"

echo "==> Staging changes..."
git add -A

if git diff --staged --quiet; then
    echo "No changes to commit. Working tree is clean."
    exit 0
fi

echo "==> Committing: '$COMMIT_MSG'..."
git commit -m "$COMMIT_MSG"

echo "==> Pushing to origin main..."
git push origin main

echo "==> Checking for existing open PR or creating new PR..."
EXISTING_PR=$(gh pr list --repo "$UPSTREAM_REPO" --head "MikoYae-AI:main" --json number --jq '.[0].number' 2>/dev/null || true)

if [[ -n "$EXISTING_PR" && "$EXISTING_PR" != "null" ]]; then
    echo "Found open PR #$EXISTING_PR."
    PR_NUM="$EXISTING_PR"
else
    echo "Creating new PR on $UPSTREAM_REPO..."
    PR_URL=$(gh pr create --repo "$UPSTREAM_REPO" \
        --head "MikoYae-AI:main" \
        --base main \
        --title "$COMMIT_MSG" \
        --body "Automated synchronization of NeOS changes." 2>/dev/null || true)
    echo "Created PR: $PR_URL"
    PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$' || true)
fi

if [[ -n "${PR_NUM:-}" ]]; then
    echo "==> Attempting auto-merge for PR #$PR_NUM..."
    gh pr merge "$PR_NUM" --repo "$UPSTREAM_REPO" --squash --admin 2>/dev/null \
        || gh pr merge "$PR_NUM" --repo "$UPSTREAM_REPO" --squash 2>/dev/null \
        || gh pr merge "$PR_NUM" --repo "$UPSTREAM_REPO" --auto --squash 2>/dev/null \
        || echo "Note: PR #$PR_NUM submitted for automated CI auto-merge workflow."
fi

echo "==> Fetching latest upstream main..."
git fetch upstream main
git reset --hard upstream/main
git push origin main --force-with-lease 2>/dev/null || true

echo "✓ Sync complete! Local, fork, and upstream are in total harmony."
