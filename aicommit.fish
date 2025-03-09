function aicommit --description "Generates commit messages from staged changes with optional staging and pushing"
    argparse 'dry-run' 'all' 'push' -- $argv

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

    if test -z "$changes"
        echo "💤 No changes to commit"
        return 0
    end

    git status --short

    # Stage all changes only if --all flag is specified
    if test "$stage_all" = true
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

    if test "$dry_run" = true
        _aipush_commit_process true
        if test "$should_push" = true
            echo "🔍 DRY RUN: Would push changes if commit successful"
        end
        # Unstage everything only if we staged it ourselves
        if test "$staged_ourselves" = true
            git reset
        end
        return 0
    end

    if _aipush_commit_process false
        echo "✨ Commit successful"

        if test "$should_push" = true
            echo "🚀 Pushing changes..."
            if git push
                echo "✅ Changes pushed successfully"
            else
                echo "💩 Push Failed"
                return 1
            end
        end
    else
        echo "💩 Commit failed"
        # Unstage everything only if we staged it ourselves
        if test "$staged_ourselves" = true
            echo "Unstaging all changes"
            git reset
        end
        return 1
    end
end

function _aipush_commit_process --argument-names dry_run
    if test "$dry_run" = true
        echo "🔍 DRY RUN: Would generate commit message and commit changes"
        return 0
    end

    set -l commit_msg ""
    set -l should_proceed false

    while test "$should_proceed" = false
        # Use generate_commit_message to get AI-generated commit message
        echo "🤖 Generating commit message..."
        set commit_msg (generate_commit_message)

        if test -z "$commit_msg"
            echo "💩 Failed to generate commit message"
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
                set should_proceed true
        end
    end

    # Commit with the message
    if git commit -m "$commit_msg"
        return 0
    else
        echo "❌ Failed to commit changes"
        return 1
    end
end

function _edit_message --argument-names message
    # Create a temp file with the message
    set -l temp_file (mktemp)
    echo "$message" > $temp_file

    # Open editor for the user to edit the message
    zed --wait $temp_file

    # Read the edited message
    set -l edited_message (cat $temp_file)

    # Clean up
    rm $temp_file

    echo "✏️ Message edited"
    echo $edited_message
end
