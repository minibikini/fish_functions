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

    # Check for commit-prompt.txt in repo root
    set -l repo_root (git rev-parse --show-toplevel)
    set -l prompt_file "$repo_root/commit-prompt.txt"

    if test -f $prompt_file
        echo "📝 Using commit prompt from commit-prompt.txt"
        set -x AIDER_COMMIT_PROMPT (cat $prompt_file)
    end

    if test "$dry_run" = true
        echo "🔍 DRY RUN: Would stage all changes"
        _aipush_commit_process true
        echo "🔍 DRY RUN: Would push changes if commit successful"
        return 0
    end

    echo "📦 Staging all changes..."
    git add --all

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

function _aipush_commit_process --argument-names dry_run
    if test "$dry_run" = true
        echo "🔍 DRY RUN: Would execute: aider --commit --no-check-update"
        aider --commit --no-check-update
        return 0
    end

    if aider --commit --no-check-update
        # Get the last commit message
        set -l commit_msg (git log -1 --pretty=%B)
        echo "📝 AI generated commit message:"
        echo "$commit_msg"

        read -l -P "🔄 Do you want to edit this commit message? (y/N) " edit_response

        if test "$edit_response" = "y" -o "$edit_response" = "Y"
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
        else
            echo "✅ Keeping original commit message"
        end

        return 0
    else
        return 1
    end
end
