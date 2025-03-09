function aicommit --description "Automatically stages and commits changes using AI-generated commit messages"
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
