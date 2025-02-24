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

### ghce (GitHub Copilot Explain)

A wrapper around `gh copilot explain` to explain commands in natural language.

**Requirements:**

- [GitHub CLI](https://cli.github.com/) (`gh`) with Copilot extension

**Usage:**

```fish
ghce [flags] <command>
```

**Flags:**

- `-d, --debug`: Enable debugging
- `-h, --help`: Display help usage
- `--hostname`: The GitHub host to use for authentication

### ghcs (GitHub Copilot Suggest)

A wrapper around `gh copilot suggest` to get command suggestions based on natural language descriptions.

**Requirements:**

- [GitHub CLI](https://cli.github.com/) (`gh`) with Copilot extension

**Usage:**

```fish
ghcs [flags] <prompt>
```

**Flags:**

- `-d, --debug`: Enable debugging
- `-h, --help`: Display help usage
- `--hostname`: The GitHub host to use for authentication
- `-t, --target`: Target for suggestion (shell, gh, git; default: "shell")

### touch-p-open

Creates parent directories if needed, creates a new file, and opens it in Zed editor.

**Requirements:**

- [Zed Editor](https://zed.dev/)

**Usage:**

```fish
touch-p-open path/to/new/file
```
