# Git Utility Scripts

Scripts that assist with maintaining Git repositories, particularly
in long-lived or high-branch-count environments.

![Git](https://img.shields.io/badge/Git-Required-orange)
![Safety](https://img.shields.io/badge/Mode-Dry%20Run%20Default-brightgreen)

---

## Available Scripts

| Script | Description |
|------|-------------|
| [`cleanup-release-branches`](cleanup-release-branches/) | Clean up old `release/DD-MM-YYYY` branches safely |

---

## Design Philosophy

- Prefer dry runs over direct deletion
- Require explicit intent (`--force`) for destructive actions
- Favor readability over clever one-liners
