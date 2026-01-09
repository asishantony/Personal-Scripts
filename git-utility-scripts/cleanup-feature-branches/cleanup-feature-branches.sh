#!/bin/bash

REMOTE="origin"
BASE_BRANCH="main"
FORCE=false
SKIP_DAYS=14   # branches updated within last N days will be skipped

show_help() {
  cat <<EOF
Usage:
  cleanup-feature-branches.sh [--force] [--help]

Description:
  Cleans up feature/* branches that are fully merged into '$BASE_BRANCH'.

Safety rules:
  - Dry run by default
  - Requires --force to delete
  - Single global confirmation
  - Skips protected branches:
      feature/release-*
      feature/hotfix-*
  - Skips branches updated in last $SKIP_DAYS days

Options:
  --force     Enable deletion
  --help      Show this help message
EOF
}

# Parse flags
case "$1" in
  --help|-h)
    show_help
    exit 0
    ;;
  --force)
    FORCE=true
    ;;
  "")
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage."
    exit 1
    ;;
esac

echo ""
echo "Base branch          : $BASE_BRANCH"
echo "Remote               : $REMOTE"
echo "Skip recent branches : < $SKIP_DAYS days"

if [[ "$FORCE" == false ]]; then
  echo "Mode                 : DRY RUN"
  echo "Tip                  : Re-run with --force to delete"
else
  echo "Mode                 : FORCE DELETE"
fi

echo ""
git fetch --prune "$REMOTE"

# Ensure remote base branch exists
if ! git show-ref --verify --quiet "refs/remotes/$REMOTE/$BASE_BRANCH"; then
  echo "Error: $REMOTE/$BASE_BRANCH not found."
  exit 1
fi

now=$(date +%s)
candidates=()
skipped_recent=0
skipped_protected=0

while read remote_branch; do
  branch="${remote_branch#$REMOTE/}"

  # Protection rules
  if [[ "$branch" == feature/release-* || "$branch" == feature/hotfix-* ]]; then
    ((skipped_protected++))
    continue
  fi

  # Last commit time on remote branch
  last_commit_ts=$(git log -1 --format=%ct "$REMOTE/$branch" 2>/dev/null)
  age_days=$(( (now - last_commit_ts) / 86400 ))

  if [[ "$age_days" -lt "$SKIP_DAYS" ]]; then
    ((skipped_recent++))
    continue
  fi

  # Merge safety check (REMOTE refs only)
  if git merge-base --is-ancestor "$REMOTE/$branch" "$REMOTE/$BASE_BRANCH"; then
    candidates+=("$branch")
  fi

done < <(git branch -r --list "$REMOTE/feature/*")

# No candidates
if [[ ${#candidates[@]} -eq 0 ]]; then
  echo ""
  echo "No eligible feature branches found."
  echo "Skipped (protected) : $skipped_protected"
  echo "Skipped (recent)    : $skipped_recent"
  exit 0
fi

echo ""
echo "Feature branches eligible for cleanup:"
for b in "${candidates[@]}"; do
  echo "  - $b"
done

echo ""
echo "Total candidates     : ${#candidates[@]}"
echo "Skipped (protected)  : $skipped_protected"
echo "Skipped (recent)     : $skipped_recent"

# Dry run exit
if [[ "$FORCE" == false ]]; then
  echo ""
  echo "Dry run completed. No changes were made."
  exit 0
fi

# Global confirmation
echo ""
read -p "Delete ALL the above feature branches locally & remotely? (yes/NO): " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborted. No branches were deleted."
  exit 0
fi

deleted=0
failed=0

for branch in "${candidates[@]}"; do
  # Delete local branch if exists
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git branch -d "$branch" || git branch -D "$branch"
  fi

  # Delete remote branch
  if git push "$REMOTE" --delete "$branch"; then
    ((deleted++))
  else
    ((failed++))
  fi
done

echo ""
echo "Cleanup summary:"
echo "  Deleted branches : $deleted"
echo "  Failed deletions : $failed"
echo "  Skipped recent   : $skipped_recent"
echo "  Skipped protected: $skipped_protected"
