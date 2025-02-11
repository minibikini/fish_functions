function gh-issue-select-develop --description "Select GitHub issue for development"

    # This function provides an interactive interface to select
    # and create development branches from GitHub issues.
    #
    # Requirements:
    #   - gh (GitHub CLI)
    #   - fzf (Fuzzy finder)
    #
    # Usage:
    #   gh-select-issue-develop

    # Define color codes
    set yellow (printf '\033[33m')
    set white (printf '\033[37m')
    set gray (printf '\033[90m')
    set reset (printf '\033[0m')

    # First, print the header separately
    printf "  $gray%-4s %-45s %-12s %s$reset\n" "ID" "TITLE" "LABELS" "UPDATED"

    # Then get and format the issues
    set issues (gh issue list --json number,title,labels,updatedAt --template '{{range .}}{{printf "'$yellow'#%-3v '$white'%-45s '$gray'%-12s %s'$reset'\n" .number .title (join " " (pluck "name" .labels)) (timeago .updatedAt)}}{{end}}')

    # Calculate height: number of issues + 2 for padding
    set issue_count (count $issues)
    set fzf_height (math "$issue_count + 2")

    # Use fzf for selection with layout=reverse-list and dynamic height
    set selected_issue (printf "%s\n" $issues | fzf --height=$fzf_height --layout=reverse-list --header-lines=0 --ansi)

    printf "\033[1A\033[2K"
    if test -n "$selected_issue"
        set issue_number (echo $selected_issue | string match -r '^#(\d+)' | tail -n1)

        if test -n "$issue_number"

            gh issue develop "#$issue_number" -c
        end
    end
end
