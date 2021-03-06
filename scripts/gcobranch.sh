#!/bin/bash
# Checks out and pulls specified {branch} in all git repos found in each of specified {dir}
# Syntax: $ gcobranch {branch} {dir1} [{dir2} {dir3}...]
source ~/.bashscripts/lib/commons.sh

erroCount=0
minArgsCount=2

if [ $# -lt $minArgsCount ]; then
    messageError "Received $# arguments, at least ${minArgsCount} required!"
    message "Syntax: gcobranch {branch} {dir1} [{dir2} {dir3}...]"
    messageExit
fi

checkoutBranch=$1
directories="${@:2}";

for dir in $directories
do
    realDir=$(getDirOrSymlinkToDir $dir)
    if [[ $realDir != 1 ]]; then
        cd $realDir>/dev/null;
        message "\nScanning ${PWD}"
        cd ->/dev/null
        for d in `findAllGitDrectories $realDir`; do
            cd $d/.. > /dev/null
            pwd=$(pwd)
            messageHighlight "\nRepo: ${pwd}"
            currentBranch=$(gitGetCurrentBranch)
            message "Current branch: ${currentBranch}"
            if [[ "${currentBranch}" != "${checkoutBranch}" ]]; then
                gitCheckoutBranchWithOrigin $checkoutBranch
                checkedout=" checked out and"
            else
                message "Already on ${checkoutBranch}"
                checkedout=""
            fi

            currentBranch=$(gitGetCurrentBranch)
            if [[ "${currentBranch}" == "${checkoutBranch}" ]]; then
                pull=$((git pull origin $checkoutBranch) 2>&1)
                lastCommit=$(gitLastCommit)
                message "Last commit: ${lastCommit}"
                messageSuccess "${checkoutBranch}${checkedout} pulled"
            fi
          cd - > /dev/null
        done
    else
        messageError "Directory ${dir} does not exist"
    fi
done

messageExit
