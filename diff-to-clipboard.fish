function diff-to-clipboard
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: Not in a git repository" >&2
        return 1
    end

    if test -z "$base_branch"
        # Try to determine default branch
        set base_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
        if test -z "$base_branch"
            set base_branch "main" # Fallback to main
        end
    end

    git log -p $base_branch..HEAD | pbcopy
    echo "`git diff` from `$base_branch` to `HEAD` copied to clipboard"
end
