function ghce -d "GH Copilot Explain"
    set -l GH_DEBUG $GH_DEBUG
    set -l GH_HOST $GH_HOST

    set -l __USAGE "Wrapper around `gh copilot explain` to explain a given input command in natural language.

USAGE
  $_ [flags] <command>

FLAGS
  -d, --debug      Enable debugging
  -h, --help       Display help usage
      --hostname   The GitHub host to use for authentication

EXAMPLES

# View disk usage, sorted by size
\$ $_ 'du -sh | sort -h'

# View git repository history as text graphical representation
\$ $_ 'git log --oneline --graph --decorate --all'

# Remove binary objects larger than 50 megabytes from git history
\$ $_ 'bfg --strip-blobs-bigger-than 50M'"

    argparse 'd/debug' 'h/help' 'hostname=' -- $argv
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

    env GH_DEBUG=$GH_DEBUG GH_HOST=$GH_HOST gh copilot explain $argv
end
