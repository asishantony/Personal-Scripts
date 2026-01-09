# cleanup-release-branches

Safely lists and deletes Git release branches that follow the naming convention:

    release/DD-MM-YYYY

Branches older than a user-provided cutoff date are selected.

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
  - Local branches (if present)
  - Remote branches (`origin`)
- Summary report at the end
- Skips invalid branch formats
- Uses `git fetch --prune`

---

## Requirements

- macOS
- zsh
- Git
- Branch naming format: `release/DD-MM-YYYY`

⚠️ Linux is not supported by default due to `date` command differences.

---

## Installation

Make the script executable:

    chmod +x cleanup-release-branches.sh

(Optional) Move it to a directory in your PATH:

    mkdir -p ~/bin
    cp cleanup-release-branches.sh ~/bin/

Ensure `~/bin` is in your PATH (`~/.zshrc`):

    export PATH="$HOME/bin:$PATH"

Reload your shell:

    source ~/.zshrc

---

## Usage

### Show help

    cleanup-release-branches.sh --help

---

### Dry run (default)

Lists branches that **would** be deleted.  
No changes are made.

    cleanup-release-branches.sh

Example output:

    Enter cutoff date (DD-MM-YYYY): 08-01-2026

    Branches older than 08-01-2026:
      - release/01-12-2025
      - release/05-01-2026

    Total candidates: 2

    Dry run completed. No changes were made.

---

### Force delete (with global confirmation)

    cleanup-release-branches.sh --force

Confirmation prompt:

    Delete ALL the above branches locally & remotely? (yes/NO):

Only typing `yes` proceeds with deletion.

---

## Summary Report

After execution, the script prints:

    Cleanup summary:
      Deleted branches : 4
      Skipped branches : 1
      Total processed  : 5

---

## Recommended Workflow

    cleanup-release-branches.sh
    # review output

    cleanup-release-branches.sh --force
    # type "yes" to confirm

---

## Safety Guarantees

- No deletion without `--force`
- No deletion without explicit confirmation
- Safe to run multiple times
- Skips malformed branch names
- Local branches deleted only if they exist

---

## Limitations

- macOS only
- Operates on `origin` remote
- Assumes strict date-based branch naming

---

## Disclaimer

Deleting remote branches affects all collaborators.  
Always perform a dry run first.

---

## License

MIT
