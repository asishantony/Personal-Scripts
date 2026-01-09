# list-unmerged-branches

Lists Git branches that contain commits **not yet merged** into a base branch
(`main` by default).

This script is **read-only** and safe to run in any environment.

---

## Badges

![Shell](https://img.shields.io/badge/Shell-Bash-blue)
![Platform](https://img.shields.io/badge/macOS-Compatible-lightgrey)
![Safety](https://img.shields.io/badge/Mode-Read%20Only-brightgreen)
![Git](https://img.shields.io/badge/Git-Required-orange)

---

## Features

- Lists branches NOT merged into a base branch
- Supports `--base` flag (`main`, `develop`, or any branch)
- Remote-safe Git ancestry checks
- Shows:
  - Branch name
  - Last commit author
  - Last commit hash
  - Commit date
  - Age (days since last commit)
- Output formats:
  - Table (default)
  - CSV
  - JSON
- Skips protected branches:
  - `feature/release-*`
  - `feature/hotfix-*`

---

## How Unmerged Status Is Determined

A branch is considered **not merged** if:

    git merge-base --is-ancestor origin/branch origin/main

returns false.

This means at least one commit exists on the branch that is not present
in the base branch.

---

## Requirements

- macOS
- zsh
- Git

---

## Installation

Make executable:

    chmod +x list-unmerged-branches.sh

(Optional) Move to PATH:

    mkdir -p ~/bin
    cp list-unmerged-branches.sh ~/bin/

Reload shell:

    source ~/.zshrc

---

## Usage

### Default (base = main)

    list-unmerged-branches.sh

---

### Use a different base branch

    list-unmerged-branches.sh --base develop

---

### CSV output

    list-unmerged-branches.sh --csv

---

### JSON output

    list-unmerged-branches.sh --json

---

### Skip recently updated branches

    list-unmerged-branches.sh --skip-days 14

---

## Example Output (table)

    feature/MAR-818-popup-fix        Asish K Antony      12d
    feature/ai-agent-layout-change  John Doe            45d

---

## Safety Notes

- No branches are modified or deleted
- Safe to run repeatedly
- Suitable for CI and audits

---

## License

MIT
