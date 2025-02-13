# fish_functions

A collection of useful Fish shell functions.

## Installation

1. Clone or download this repository to your preferred location
2. Add the repository path to your fish function path:

   ```fish
   # Add to your ~/.config/fish/config.fish
   set -a fish_function_path /path/to/this/repository
   ```

3. Reload your fish shell or run:

   ```fish
   source ~/.config/fish/config.fish
   ```

## Available Functions

### gh-issue-select-develop

Interactive GitHub issue selector for development branches.

https://github.com/user-attachments/assets/4c4284ff-368b-40f8-8cde-d759da3758ed

**Requirements:**

- [GitHub CLI](https://cli.github.com/) (`gh`)
- [fzf](https://github.com/junegunn/fzf) (Fuzzy finder)

**Usage:**

```fish
gh-issue-select-develop
```

Quickly select a GitHub issue and create a development branch for it. Uses fuzzy search to find the right issue and automatically checks out the new branch.
