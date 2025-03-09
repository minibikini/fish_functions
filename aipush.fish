function aipush --description "Automatically stages and commits changes using AI-generated commit messages"
    argparse 'dry-run' -- $argv

    set -l dry_run false
    if set -q _flag_dry_run
        set dry_run true
    end

    echo "📋 Current repository status:"
    set -l changes (git status --porcelain)

    if test -z "$changes"
        echo "💤 No changes to commit"
        return 0
    end

    git status --short

    # Stage all changes including untracked files at the beginning
    echo "📦 Staging all changes, including untracked files..."
    git add --all

    if test "$dry_run" = true
        _aipush_commit_process true
        echo "🔍 DRY RUN: Would push changes if commit successful"
        # Unstage everything since this is just a dry run
        git reset
        return 0
    end

    if _aipush_commit_process false
        echo "✨ Commit successful, pushing changes..."

        if git push
            echo "✅ Changes pushed successfully"
        else
            echo "💩 Push Failed"
            return 1
        end
    else
        echo "💩 Commit failed, unstaging all changes"
        git reset
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
                echo "🚫 Commit process aborted, unstaging changes"
                git reset  # Unstage all changes
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
