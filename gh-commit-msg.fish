function gh-commit-msg -d "Generate Git commit messages using GitHub Models"
    argparse 'p/prompt-file=' -- $argv

    # Define the default prompt
    set default_prompt "You are an expert software engineer that generates concise, one-line Git commit messages based on the provided diffs.

    Review the provided context and diffs which are about to be committed to a git repo.

    Review the diffs carefully.

    Generate a one-line commit message for those changes.
    The commit message should be structured as follows:

    <type>: <description>

    Use these for <type>: fix, feat, build, chore, ci, docs, style, refactor, perf, test

    Ensure the commit message:
    - Starts with the appropriate prefix.
    - Is in the imperative mood (e.g., \"Add feature\" not \"Added feature\" or \"Adding feature\").
    - Does not exceed 72 characters.

    Reply only with the one-line commit message, without any additional text, explanations, or line breaks.

    Staged files:
    %STAGED_FILES%

    Changes:
    %DIFF_OUTPUT%"

    set prompt_text $default_prompt

    # Check for prompt file parameter
    if set -q _flag_prompt_file
        if test -f $_flag_prompt_file
            set prompt_text (cat $_flag_prompt_file)
        end
    # If no prompt file specified, look for commit-prompt.md in current directory
    else if test -f "commit-prompt.md"
        set prompt_text (cat "commit-prompt.md")
    end

    # Get the staged changes
    set diff_output (git diff --cached)

    # If nothing is staged, inform the user
    if test -z "$diff_output"
        echo "No changes staged for commit."
        return 1
    end

    # Get the list of staged files for context
    set staged_files (git diff --cached --name-status | string collect)

    # Replace placeholders in the prompt with actual data
    set prompt_with_files (string replace '%STAGED_FILES%' "$staged_files" "$prompt_text")
    set final_prompt (string replace '%DIFF_OUTPUT%' "$diff_output" "$prompt_with_files")

    # Send to LLM via gh CLI and display the result
    echo "$final_prompt" | gh models run gpt-4o
end
