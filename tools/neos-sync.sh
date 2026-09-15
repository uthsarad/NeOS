#!/usr/bin/env bash
# NeOS Automated Commit, PR, & Sync Utility
# Automatically commits changes, pushes to fork, opens a PR on upstream,
# and synchronizes the local repository with upstream main.

set -euo pipefail

COMMIT_MSG="${1:-"🔄 Update: Synchronize NeOS modifications"}"
UPSTREAM_REPO="uthsarad/NeOS"
TARGET_BRANCH="${TARGET_BRANCH:-testing}"
CURRENT_BRANCH="$(git branch --show-current)"

echo "==> Staging changes..."
git add -A

if git diff --staged --quiet; then
    echo "No changes to commit. Working tree is clean."
    exit 0
fi

echo "==> Committing: '$COMMIT_MSG'..."
git commit -m "$COMMIT_MSG"

echo "==> Pushing to origin $CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

echo "==> Checking for existing open PR or creating new PR on $TARGET_BRANCH..."
EXISTING_PR=$(gh pr list --repo "$UPSTREAM_REPO" --base "$TARGET_BRANCH" --head "MikoYae-AI:$CURRENT_BRANCH" --json number --jq '.[0].number' 2>/dev/null || true)

if [[ -n "$EXISTING_PR" && "$EXISTING_PR" != "null" ]]; then
    echo "Found open PR #$EXISTING_PR."
    PR_NUM="$EXISTING_PR"
else
    echo "Creating new PR on $UPSTREAM_REPO ($TARGET_BRANCH)..."
    PR_URL=$(gh pr create --repo "$UPSTREAM_REPO" \
        --head "MikoYae-AI:$CURRENT_BRANCH" \
        --base "$TARGET_BRANCH" \
        --title "$COMMIT_MSG" \
        --body "Automated synchronization of NeOS changes." 2>/dev/null || true)
    echo "Created PR: $PR_URL"
    PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$' || true)
fi

if [[ -n "${PR_NUM:-}" ]]; then
    echo "==> Monitoring auto-merge for PR #$PR_NUM..."
    for _ in {1..20}; do
        PR_STATE=$(gh pr view "$PR_NUM" --repo "$UPSTREAM_REPO" --json state --jq .state 2>/dev/null || true)
        if [[ "$PR_STATE" == "MERGED" ]]; then
            echo "✓ PR #$PR_NUM merged upstream!"
            break
        elif [[ "$PR_STATE" == "CLOSED" ]]; then
            echo "PR #$PR_NUM was closed."
            break
        fi
        sleep 2
    done
fi

echo "==> Fetching latest upstream $TARGET_BRANCH..."
git fetch upstream "$TARGET_BRANCH"

PR_FINAL_STATE=$(gh pr view "${PR_NUM:-0}" --repo "$UPSTREAM_REPO" --json state --jq .state 2>/dev/null || true)
if [[ "$PR_FINAL_STATE" == "MERGED" ]]; then
    git reset --hard "upstream/$TARGET_BRANCH"
    git push origin "$CURRENT_BRANCH" --force-with-lease 2>/dev/null || true
fi

echo "✓ Sync complete! Local, fork, and upstream are in total harmony on $TARGET_BRANCH."
