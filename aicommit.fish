function aicommit --description "Generates commit messages from staged changes with optional staging and pushing"
    argparse 'd/dry-run' 'a/all' 'p/push' -- $argv

    set -l dry_run false
    set -l stage_all false
    set -l should_push false

    if set -q _flag_dry_run
        set dry_run true
    end

    if set -q _flag_all
        set stage_all true
    end

    if set -q _flag_push
        set should_push true
    end

    echo "📋 Current repository status:"
    set -l changes (git status --porcelain)
    echo

    if test -z "$changes"
        echo "💤 No changes to commit"
        return 0
    end

    git status --short

    # Stage all changes only if --all flag is specified
    if $stage_all
        echo "📦 Staging all changes, including untracked files..."
        git add --all
        set staged_ourselves true
    else
        echo "📦 Using currently staged files..."
        set staged_ourselves false
    end

    # Check if there are any staged changes
    set -l staged_changes (git diff --cached --name-only)
    if test -z "$staged_changes"
        echo "💤 No staged changes to commit. Use --all to stage and commit all changes."
        return 0
    end

    if $dry_run
        set_color --bold yellow
        echo "🔍 DRY RUN MODE: No actual changes will be committed or pushed"
        set_color normal
        _commit_process $dry_run
        if $should_push
            set_color --bold yellow
            echo "🔍 DRY RUN: Would push changes if commit successful"
            set_color normal
        end
        # Unstage everything only if we staged it ourselves
        if $staged_ourselves
            set_color --bold yellow
            echo "🔍 DRY RUN: Would unstage all changes we staged"
            set_color normal
        end
        return 0
    end

    if _commit_process $dry_run
        echo "✨ Commit successful"

        if $should_push
            echo "🚀 Pushing changes..."
            set -l push_output (git push 2>&1)
            set -l push_status $status
            if test $push_status -eq 0
                echo "✅ Changes pushed successfully"
            else
                set_color red
                echo "💩 Push Failed: $push_output"
                set_color normal
                return 1
            end
        end
    else
        echo "💩 Commit failed"
        # Unstage everything only if we staged it ourselves
        if $staged_ourselves
            echo "Unstaging all changes"
            git reset
        end
        return 1
    end
end

function _commit_process --argument-names dry_run
    if $dry_run
        set_color --bold yellow
        echo "🔍 DRY RUN: Would generate commit message and commit changes"
        set_color normal
        return 0
    end

    set -l commit_msg ""
    set -l should_proceed false

    while not $should_proceed
        # Use gh-commit-msg to get AI-generated commit message
        echo "🤖 Generating commit message..."
        set commit_msg (gh-commit-msg)

        if test -z "$commit_msg"
            set_color red
            echo "💩 Failed to generate commit message"
            set_color normal
            return 1
        end

        echo "📝 Generated commit message:"
        echo
        set_color green
        echo "$commit_msg"
        set_color normal
        echo

        echo "Options:"
        echo "  (c) ✅  Commit with this message"
        echo "  (e) 📝  Edit message before commit"
        echo "  (r) 🔄  Regenerate new message"
        echo "  (q) 🚫  Quit without committing"
        echo
        read -l -P "What would you like to do? [c]: " action

        switch $action
            case "c" ""
                set should_proceed true
            case "e"
                set commit_msg (_edit_message "$commit_msg")
                set should_proceed true
            case "r"
                echo "🔄 Regenerating message..."
                # Loop will continue
            case "q"
                echo "🚫 Commit process aborted"
                return 1
            case "*"
                set_color yellow
                echo "⚠️ Invalid input. Please select c, e, r, or q."
                set_color normal
                # Loop continues to prompt again
        end
    end

    # Commit with the message
    set -l commit_output (git commit -m "$commit_msg" 2>&1)
    set -l commit_status $status
    if test $commit_status -eq 0
        return 0
    else
        set_color red
        echo "❌ Failed to commit changes: $commit_output"
        set_color normal
        return 1
    end
end

function _edit_message --argument-names message
    # Create a temp file with the message
    set -l temp_file (mktemp)
    echo "$message" > $temp_file

    # Find available editor
    set -l editor $EDITOR
    if test -z "$editor"
        if type -q zed
            set editor "zed --wait"
        else if type -q code
            set editor "code --wait"
        else if type -q nano
            set editor "nano"
        else
            set editor "vi"
        end
    end

    # Open editor for the user to edit the message
    eval "$editor $temp_file"

    # Read the edited message
    set -l edited_message (cat $temp_file)

    # Clean up
    rm $temp_file

    echo "✏️ Message edited"
    echo $edited_message
end
