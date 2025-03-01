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

    _handle_untracked_files
    _load_commit_prompt

    if test "$dry_run" = true
        _aipush_commit_process true
        echo "🔍 DRY RUN: Would push changes if commit successful"
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
        echo "💩 Commit failed, not pushing"
        return 1
    end
end

function _handle_untracked_files
    set -l untracked_changes (git status --porcelain | awk '$1 == "??"')
    if test -n "$untracked_changes"
        echo "⚠️ Untracked changes detected:"
        echo "$untracked_changes"
        read -l -P "🤔 Stage untracked changes as well? (Y/n): " stage_untracked
        if test "$stage_untracked" != "n"
            echo "📦 Staging all changes, including untracked files..."
            git add --all
        else
            echo "🚫 Skipping untracked files"
        end
    end
end

function _load_commit_prompt
    set -l repo_root (git rev-parse --show-toplevel)
    set -g prompt_file "$repo_root/commit-prompt.txt"
    set -g commit_prompt_md "$repo_root/commit-prompt.md"

    if test -f $commit_prompt_md
        echo "📝 Using commit prompt from commit-prompt.md"
        set -x AIDER_COMMIT_PROMPT (cat $commit_prompt_md)
    else if test -f $prompt_file
        echo "📝 Using commit prompt from commit-prompt.txt"
        set -x AIDER_COMMIT_PROMPT (cat $prompt_file)
    end
end

function _aipush_commit_process --argument-names dry_run
    if test "$dry_run" = true
        echo "🔍 DRY RUN: Would commit changes with 'aider --commit'"
        return 0
    end

    if not aider --commit --no-check-update
        return 1
    end

    # Get the last commit message
    set -l commit_msg (git log -1 --pretty=%B)

    echo "Options:"
    echo "  (k) ✅  Keep as is (default)"
    echo "  (e) 📝  Edit the commit message"
    echo "  (u) ⏪  Undo this commit"
    echo
    read -l -P "🔄 What would you like to do? [k]: " edit_response

    switch $edit_response
        case "e" "E"
            _edit_commit_message "$commit_msg"
        case "u" "U"
            git reset HEAD~1
            echo "⏪ Last commit undone, changes are back in staging area"
            return 1
        case "*"
            echo "✅ Keeping original commit message"
    end

    return 0
end

function _edit_commit_message --argument-names commit_msg
    # Create a temp file with the commit message
    set -l temp_file (mktemp)
    echo "$commit_msg" > $temp_file

    # Open editor for the user to edit the message
    zed --wait $temp_file

    # Amend the commit with the new message
    git commit --amend -F $temp_file

    # Clean up
    rm $temp_file

    echo "✏️ Commit message updated"
end
