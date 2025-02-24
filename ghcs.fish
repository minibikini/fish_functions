complete -c ghcs -s t -l target -x -a '
    shell\t"Suggest shell commands (default)"
    gh\t"Suggest GitHub CLI commands"
    git\t"Suggest Git commands"
' -d "Target for suggestion"
complete -c ghcs -s d -l debug -d "Enable debugging"
complete -c ghcs -s h -l help -d "Display help usage"
complete -c ghcs -l hostname -d "The GitHub host to use for authentication"

function ghcs -d "GH Copilot Suggest"
    set -l TARGET "shell"
    set -l GH_DEBUG $GH_DEBUG
    set -l GH_HOST $GH_HOST

    set -l __USAGE "Wrapper around `gh copilot suggest` to suggest a command based on a natural language description of the desired output effort.
Supports executing suggested commands if applicable.

USAGE
  $_ [flags] <prompt>

FLAGS
  -d, --debug              Enable debugging
  -h, --help               Display help usage
      --hostname           The GitHub host to use for authentication
  -t, --target target      Target for suggestion; must be shell, gh, git
                           default: \"$TARGET\"

EXAMPLES

- Guided experience
  \$ $_

- Git use cases
  \$ $_ -t git \"Undo the most recent local commits\"
  \$ $_ -t git \"Clean up local branches\"
  \$ $_ -t git \"Setup LFS for images\"

- Working with the GitHub CLI in the terminal
  \$ $_ -t gh \"Create pull request\"
  \$ $_ -t gh \"List pull requests waiting for my review\"
  \$ $_ -t gh \"Summarize work I have done in issues and pull requests for promotion\"

- General use cases
  \$ $_ \"Kill processes holding onto deleted files\"
  \$ $_ \"Test whether there are SSL/TLS issues with github.com\"
  \$ $_ \"Convert SVG to PNG and resize\"
  \$ $_ \"Convert MOV to animated PNG\""

    argparse 'd/debug' 'h/help' 'hostname=' 't/target=' -- $argv
    or return

    if set -q _flag_help
        echo $__USAGE
        return 0
    end

    if set -q _flag_debug
        set GH_DEBUG api
    end

    if set -q _flag_hostname
        set GH_HOST $_flag_hostname
    end

    if set -q _flag_target
        set TARGET $_flag_target
    end

    set -l TMPFILE (mktemp -t gh-copilotXXXXXX)
    function cleanup --on-event fish_exit
        rm -f $TMPFILE
    end

    if env GH_DEBUG=$GH_DEBUG GH_HOST=$GH_HOST gh copilot suggest -t $TARGET $argv --shell-out $TMPFILE
        if test -s $TMPFILE
            set -l FIXED_CMD (cat $TMPFILE)
            # Add both commands to history
            echo $history[1] >> ~/.local/share/fish/fish_history
            echo $FIXED_CMD >> ~/.local/share/fish/fish_history
            echo
            eval $FIXED_CMD
        end
    else
        return 1
    end
end
