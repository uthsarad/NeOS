#!/usr/bin/env bash
# NeOS Commit, PR, & Sync Utility
# Commits staged/modified changes, pushes to the contributor's remote, opens or
# reuses a PR against upstream, and fast-forwards after merge.

set -euo pipefail

COMMIT_MSG="${1:-"Update: Synchronize NeOS modifications"}"
UPSTREAM_REPO="${UPSTREAM_REPO:-uthsarad/NeOS}"
TARGET_BRANCH="${TARGET_BRANCH:-testing}"
CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "Error: Detached HEAD; switch to a named branch first." >&2
    exit 1
fi

echo "==> Staging changes..."
git add -A

if git diff --staged --quiet; then
    echo "No changes to commit. Working tree is clean."
    exit 0
fi

echo "==> Committing: '$COMMIT_MSG'..."
git commit -m "$COMMIT_MSG"

PUSH_REMOTE="origin"
if git remote get-url fork >/dev/null 2>&1; then
    PUSH_REMOTE="fork"
fi

# Derive the fork owner dynamically from the push remote URL or authenticated gh user.
REMOTE_URL="$(git remote get-url "$PUSH_REMOTE" 2>/dev/null || true)"
FORK_OWNER=""
if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/ ]]; then
    FORK_OWNER="${BASH_REMATCH[1]}"
fi
if [[ -z "$FORK_OWNER" ]]; then
    FORK_OWNER="$(gh api user --jq .login 2>/dev/null || true)"
fi
if [[ -z "$FORK_OWNER" ]]; then
    echo "Error: Could not determine GitHub owner for remote '$PUSH_REMOTE'." >&2
    exit 1
fi

echo "==> Pushing to $PUSH_REMOTE $CURRENT_BRANCH..."
git push "$PUSH_REMOTE" "$CURRENT_BRANCH"

HEAD_SPEC="${FORK_OWNER}:${CURRENT_BRANCH}"
echo "==> Checking for existing open PR or creating new PR on $TARGET_BRANCH ($HEAD_SPEC)..."
EXISTING_PR=$(gh pr list --repo "$UPSTREAM_REPO" --base "$TARGET_BRANCH" --head "$HEAD_SPEC" --json number --jq '.[0].number' 2>/dev/null || true)

if [[ -n "$EXISTING_PR" && "$EXISTING_PR" != "null" ]]; then
    echo "Found open PR #$EXISTING_PR."
    PR_NUM="$EXISTING_PR"
else
    echo "Creating new PR on $UPSTREAM_REPO ($TARGET_BRANCH)..."
    PR_URL=$(gh pr create --repo "$UPSTREAM_REPO" \
        --head "$HEAD_SPEC" \
        --base "$TARGET_BRANCH" \
        --title "$COMMIT_MSG" \
        --body "Synchronization of NeOS changes." 2>/dev/null || true)
    echo "Created PR: $PR_URL"
    PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$' || true)
fi

if [[ -n "${PR_NUM:-}" ]]; then
    echo "==> Monitoring PR #$PR_NUM status..."
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

UPSTREAM_REMOTE="upstream"
if ! git remote get-url upstream >/dev/null 2>&1; then
    UPSTREAM_REMOTE="origin"
fi

echo "==> Fetching latest $UPSTREAM_REMOTE $TARGET_BRANCH..."
git fetch "$UPSTREAM_REMOTE" "$TARGET_BRANCH"

echo "✓ Sync complete."
