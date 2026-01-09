# cleanup-feature-branches

Safely lists and deletes Git feature branches that follow the naming convention:

    feature/*

Only branches where **all commits are already merged into the `main` branch**
are selected for deletion.

---

## Badges

![Shell](https://img.shields.io/badge/Shell-Bash-blue)
![Platform](https://img.shields.io/badge/macOS-Compatible-lightgrey)
![Safety](https://img.shields.io/badge/Mode-Dry%20Run%20Default-brightgreen)
![Git](https://img.shields.io/badge/Git-Required-orange)

---

## Features

- Dry run by default (no deletion)
- `--force` flag required to delete branches
- Single global confirmation prompt
- Deletes both:
  - Local feature branches (if present)
  - Remote feature branches (`origin`)
- Uses Git ancestry checks to ensure branches are fully merged
- Summary report at the end
- Safe to re-run multiple times

---

## How Merge Safety Is Determined

A `feature/*` branch is considered safe to delete only if:

    git merge-base --is-ancestor feature-branch main

This guarantees **every commit in the feature branch already exists in `main`**.

No commit counting.  
No heuristics.  
Git-level correctness.

---

## Requirements

- macOS
- zsh
- Git
- Base branch: `main`
- Feature branch naming format: `feature/*`

⚠️ Linux is not supported by default due to `date` and shell differences.

---

## Installation

Make the script executable:

    chmod +x cleanup-feature-branches.sh

(Optional) Move it to a directory in your PATH:

    mkdir -p ~/bin
    cp cleanup-feature-branches.sh ~/bin/

Ensure `~/bin` is in your PATH (`~/.zshrc`):

    export PATH="$HOME/bin:$PATH"

Reload your shell:

    source ~/.zshrc

---

## Usage

### Show help

    cleanup-feature-branches.sh --help

---

### Dry run (default)

Lists feature branches that **would** be deleted.  
No changes are made.

    cleanup-feature-branches.sh

Example output:

    Feature branches fully merged into 'main':
      - feature/login-refactor
      - feature/header-cleanup

    Total candidates: 2

    Dry run completed. No changes were made.

---

### Force delete (with global confirmation)

    cleanup-feature-branches.sh --force

Confirmation prompt:

    Delete ALL the above feature branches locally & remotely? (yes/NO):

Only typing `yes` proceeds with deletion.

---

## Summary Report

After execution, the script prints:

    Cleanup summary:
      Deleted branches : 3
      Skipped branches : 0
      Total processed  : 3

---

## Recommended Workflow

    cleanup-feature-branches.sh
    # review output

    cleanup-feature-branches.sh --force
    # type "yes" to confirm

---

## Safety Guarantees

- Never deletes unmerged feature branches
- Uses Git ancestry checks (`merge-base`)
- No deletion without `--force`
- No deletion without explicit confirmation
- Local branches deleted only if they exist
- Safe for shared repositories

---

## Limitations

- macOS only
- Operates on `origin` remote
- Assumes `main` as the base branch
- Assumes `feature/*` naming convention

---

## Disclaimer

Deleting remote branches affects all collaborators.  
Always perform a dry run first.

---

## License

MIT
