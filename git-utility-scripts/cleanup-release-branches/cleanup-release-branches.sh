#!/bin/bash

REMOTE="origin"
FORCE=false

show_help() {
  cat <<EOF
Usage:
  cleanup-release-branches.sh [--force] [--help]

Description:
  Cleans up Git release branches following the pattern:
    release/DD-MM-YYYY

  Branches older than the provided cutoff date are selected.

Modes:
  Default (dry run):
    Lists branches that WOULD be deleted.

  --force:
    Deletes branches after ONE global confirmation.

Options:
  --force     Enable deletion
  --help      Show this help message

Examples:
  cleanup-release-branches.sh
  cleanup-release-branches.sh --force
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

# Ask for cutoff date
read -p "Enter cutoff date (DD-MM-YYYY): " CUTOFF

if ! date -j -f "%d-%m-%Y" "$CUTOFF" >/dev/null 2>&1; then
  echo "Invalid date format. Use DD-MM-YYYY."
  exit 1
fi

cutoff_date=$(date -j -f "%d-%m-%Y" "$CUTOFF" "+%Y%m%d")

echo ""
echo "Cutoff date : $CUTOFF"
echo "Remote      : $REMOTE"

if [[ "$FORCE" == false ]]; then
  echo "Mode        : DRY RUN"
  echo "Tip         : Re-run with --force to delete"
else
  echo "Mode        : FORCE DELETE"
fi

echo ""
git fetch --prune

# Collect candidate branches
candidates=()

while read remote_branch; do
  branch_name="${remote_branch#$REMOTE/}"
  date_part="${branch_name#release/}"

  if ! date -j -f "%d-%m-%Y" "$date_part" >/dev/null 2>&1; then
    continue
  fi

  branch_date=$(date -j -f "%d-%m-%Y" "$date_part" "+%Y%m%d")

  if [[ "$branch_date" -lt "$cutoff_date" ]]; then
    candidates+=("$branch_name")
  fi
done < <(git branch -r --list "$REMOTE/release/*")

# No branches found
if [[ ${#candidates[@]} -eq 0 ]]; then
  echo "No release branches older than $CUTOFF found."
  exit 0
fi

# List candidates
echo ""
echo "Branches older than $CUTOFF:"
for b in "${candidates[@]}"; do
  echo "  - $b"
done

echo ""
echo "Total candidates: ${#candidates[@]}"

# Dry run exit
if [[ "$FORCE" == false ]]; then
  echo ""
  echo "Dry run completed. No changes were made."
  exit 0
fi

# Global confirmation
echo ""
read -p "Delete ALL the above branches locally & remotely? (yes/NO): " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborted. No branches were deleted."
  exit 0
fi

# Deletion counters
deleted=0
skipped=0

# Perform deletion
for branch in "${candidates[@]}"; do
  # Delete local branch if exists
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git branch -d "$branch" || git branch -D "$branch"
  fi

  # Delete remote branch
  if git push "$REMOTE" --delete "$branch"; then
    ((deleted++))
  else
    ((skipped++))
  fi
done

# Summary
echo ""
echo "Cleanup summary:"
echo "  Deleted branches : $deleted"
echo "  Skipped branches : $skipped"
echo "  Total processed  : ${#candidates[@]}"
