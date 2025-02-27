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
        echo "🔍 DRY RUN: Would execute: aider --commit --no-auto-commits --no-check-update"
        aider --commit --no-auto-commits --no-check-update
        echo "🔍 DRY RUN: Would push changes if commit successful"
        return 0
    end

    echo "📦 Staging all changes..."
    git add --all

    if aider --commit --no-check-update
        echo "✨ Aider commit successful, pushing changes..."

        if git push
            echo "✅ Changes pushed successfully"
        else
            echo "💩 Push Failed"
            return 1
        end
    else
        echo "💩 `aider --commit` failed, not pushing"
        return 1
    end
end
