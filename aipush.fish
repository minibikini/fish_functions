function aipush --description "Automatically stages and commits changes using AI-generated commit messages"
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
