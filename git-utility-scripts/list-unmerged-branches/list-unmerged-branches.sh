#!/bin/bash

REMOTE="origin"
BASE_BRANCH="main"
OUTPUT="table"   # table | csv | json
SKIP_DAYS=0

show_help() {
  cat <<EOF
Usage:
  list-unmerged-branches.sh [options]

Options:
  --base <branch>     Base branch to compare against (default: main)
  --csv               Output in CSV format
  --json              Output in JSON format
  --skip-days <N>     Skip branches updated in last N days
  --help              Show help

Examples:
  list-unmerged-branches.sh
  list-unmerged-branches.sh --base develop
  list-unmerged-branches.sh --csv
  list-unmerged-branches.sh --json --skip-days 14
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE_BRANCH="$2"
      shift 2
      ;;
    --csv)
      OUTPUT="csv"
      shift
      ;;
    --json)
      OUTPUT="json"
      shift
      ;;
    --skip-days)
      SKIP_DAYS="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done

git fetch --prune "$REMOTE" >/dev/null

if ! git show-ref --verify --quiet "refs/remotes/$REMOTE/$BASE_BRANCH"; then
  echo "Error: $REMOTE/$BASE_BRANCH not found."
  exit 1
fi

now=$(date +%s)
results=()

while read remote_branch; do
  branch="${remote_branch#$REMOTE/}"

  [[ "$branch" == "$BASE_BRANCH" ]] && continue

  # Protected patterns
  if [[ "$branch" == feature/release-* || "$branch" == feature/hotfix-* ]]; then
    continue
  fi

  last_commit_ts=$(git log -1 --format=%ct "$REMOTE/$branch" 2>/dev/null)
  age_days=$(( (now - last_commit_ts) / 86400 ))

  if [[ "$SKIP_DAYS" -gt 0 && "$age_days" -lt "$SKIP_DAYS" ]]; then
    continue
  fi

  if ! git merge-base --is-ancestor "$REMOTE/$branch" "$REMOTE/$BASE_BRANCH"; then
    author=$(git log -1 --format=%an "$REMOTE/$branch")
    commit=$(git log -1 --format=%h "$REMOTE/$branch")
    date=$(git log -1 --format=%ad --date=short "$REMOTE/$branch")

    results+=("$branch|$author|$commit|$date|$age_days")
  fi

done < <(git branch -r --list "$REMOTE/*")

# Output
if [[ "$OUTPUT" == "csv" ]]; then
  echo "branch,author,last_commit,commit_date,age_days"
  for r in "${results[@]}"; do
    echo "${r//|/,}"
  done
elif [[ "$OUTPUT" == "json" ]]; then
  echo "["
  for i in "${!results[@]}"; do
    IFS="|" read -r b a c d age <<< "${results[$i]}"
    comma=$([[ "$i" -lt $((${#results[@]} - 1)) ]] && echo ",")
    echo "  {\"branch\":\"$b\",\"author\":\"$a\",\"commit\":\"$c\",\"date\":\"$d\",\"age_days\":$age}$comma"
  done
  echo "]"
else
  echo ""
  echo "Branches NOT merged into '$BASE_BRANCH':"
  for r in "${results[@]}"; do
    IFS="|" read -r b a c d age <<< "$r"
    printf "  %-45s %-20s %5sd\n" "$b" "$a" "$age"
  done
  echo ""
  echo "Total unmerged branches: ${#results[@]}"
fi
