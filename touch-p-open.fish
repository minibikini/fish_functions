function touch-p-open
    mkdir -p (dirname $argv)
    touch $argv
    zed $argv
end
