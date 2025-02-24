function run_pleroma_sync
    cd ~/repos/pleroma
    git pull upstream develop
    git push origin develop
    cd -
    echo "Pleroma sync complete."
end
