#!/bin/bash
# ============================================================
# EE499-FYP Auto-Sync Script
# Watches the local repo for changes and syncs with GitHub.
# Handles merge conflicts automatically by preserving both
# versions — local edits are saved to a backup branch.
# Usage:  bash auto_sync.sh [interval_seconds]
#         Default interval: 60 seconds
# Stop:   Ctrl+C or close the terminal
# ============================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
INTERVAL="${1:-60}"
BRANCH="main"
REMOTE="origin"
LOGFILE="$REPO_DIR/.sync_log.txt"

cd "$REPO_DIR" || { echo "ERROR: Cannot access $REPO_DIR"; exit 1; }

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOGFILE"
}

echo "=== EE499-FYP Auto-Sync ==="
echo "Repo:     $REPO_DIR"
echo "Remote:   $REMOTE/$BRANCH"
echo "Interval: ${INTERVAL}s"
echo "Started:  $(date)"
echo "Log:      $LOGFILE"
echo "Press Ctrl+C to stop."
echo "==========================="

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    HOSTNAME=$(hostname)

    # ---- Step 1: Commit any local changes before pulling ----
    if [ -n "$(git status --porcelain)" ]; then
        git add -A
        git commit -m "Auto-sync from $HOSTNAME at $TIMESTAMP"
        log "Committed local changes."
    fi

    # ---- Step 2: Fetch remote state ----
    git fetch "$REMOTE" "$BRANCH" 2>/dev/null

    # Check if local and remote have diverged
    LOCAL_HEAD=$(git rev-parse HEAD)
    REMOTE_HEAD=$(git rev-parse "$REMOTE/$BRANCH" 2>/dev/null)
    MERGE_BASE=$(git merge-base HEAD "$REMOTE/$BRANCH" 2>/dev/null)

    if [ "$LOCAL_HEAD" = "$REMOTE_HEAD" ]; then
        # Already in sync — nothing to do
        sleep "$INTERVAL"
        continue
    fi

    if [ "$LOCAL_HEAD" = "$MERGE_BASE" ]; then
        # Local is behind remote — fast-forward pull
        git merge --ff-only "$REMOTE/$BRANCH" 2>/dev/null
        log "Fast-forwarded to remote."
        sleep "$INTERVAL"
        continue
    fi

    if [ "$REMOTE_HEAD" = "$MERGE_BASE" ]; then
        # Remote is behind local — just push
        if git push "$REMOTE" "$BRANCH"; then
            log "Pushed local changes."
        else
            log "Push failed — will retry next cycle."
        fi
        sleep "$INTERVAL"
        continue
    fi

    # ---- Step 3: Both sides have new commits (diverged) ----
    log "Divergence detected — attempting auto-merge."

    if git merge "$REMOTE/$BRANCH" -m "Auto-merge remote changes into local ($HOSTNAME)"; then
        # Merge succeeded without conflicts
        if git push "$REMOTE" "$BRANCH"; then
            log "Auto-merged and pushed successfully."
        else
            log "Merged locally but push failed — will retry."
        fi
    else
        # Merge conflict — abort and preserve both versions
        git merge --abort
        BACKUP_BRANCH="backup/${HOSTNAME}/$(date '+%Y%m%d_%H%M%S')"
        git branch "$BACKUP_BRANCH"
        log "CONFLICT: Local work saved to branch '$BACKUP_BRANCH'."

        # Reset main to match remote so syncing can continue
        git reset --hard "$REMOTE/$BRANCH"
        log "Reset $BRANCH to remote state. Resolve conflicts by comparing with '$BACKUP_BRANCH'."
        log "  -> Run: git diff $BRANCH $BACKUP_BRANCH"
    fi

    sleep "$INTERVAL"
done
