# fish_functions

My personal fish function collection.

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

### `ghce` (GitHub Copilot Explain)

A wrapper around `gh copilot explain` to explain commands in natural language.

**Requirements:**

- [`gh`](https://cli.github.com/) with Copilot extension

**Usage:**

```fish
ghce [flags] <command>
```

**Flags:**

- `-d, --debug`: Enable debugging
- `-h, --help`: Display help usage
- `--hostname`: The GitHub host to use for authentication

### `ghcs` (GitHub Copilot Suggest)

A wrapper around `gh copilot suggest` to get command suggestions based on natural language descriptions.

**Requirements:**

- [`gh`](https://cli.github.com/) with Copilot extension

**Usage:**

```fish
ghcs [flags] <prompt>
```

**Flags:**

- `-d, --debug`: Enable debugging
- `-h, --help`: Display help usage
- `--hostname`: The GitHub host to use for authentication
- `-t, --target`: Target for suggestion (shell, gh, git; default: "shell")

### `gh-commit-msg`

Generate Git commit messages using GitHub Models.

**Requirements:**

- [`gh`](https://cli.github.com/) with models support

**Usage:**

```fish
gh-commit-msg [flags]
```

**Flags:**

- `-p, --prompt-file`: Optional path to a custom prompt file

**Features:**

- Analyzes staged changes in a git repository
- Generates concise, well-structured commit messages
- Supports custom prompts via command-line flag or `commit-prompt.md` file
- Uses GitHub Models (GPT-4o) for generating high-quality commit messages
