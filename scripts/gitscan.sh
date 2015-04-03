#!/bin/bash
# Scan all directories {dir} for git repositories and perform actions based on options
# Syntax: $ gitscan [options] {dir1} [{dir2} {dir3}...]
# Options:
# -o update remote origin links from oauth/ssh to https://
# -m list all modified files
# -c create test and development branches in sync with origin
source ~/.bashscripts/lib/commons.sh

function updateOriginUrl {
    local currentOrigin=$(gitGetCurrentOrigin)
    local httpsOrigin=$(gitOriginAnyToHttps)
    message "Current origins URL: ${currentOrigin}"
    if [[ "${currentOrigin}" != "${httpsOrigin}" ]]; then
        gitSetCurrentOrigin $httpsOrigin
        local newOrigin=$(gitGetCurrentOrigin)
        if [[ "${newOrigin}" =  "${httpsOrigin}" ]]; then
            messageSuccess "Origins url changed to ${newOrigin}"
        else
            messageError "Unable to change origins url"
        fi
    else
        message "URL OK"
    fi
}

function listAllModifiedFiles {
    modified=$(git status --porcelain)
    if [ -n "$modified" ]; then
        messageSuccess "\nModified files found in ${1}"
        git status --porcelain
    fi
}

function createBranches {
    currentBranch=$(gitGetCurrentOrigin)
    gitCheckout master
    gitFetchAll
    for branch in "$@"
    do
        message "Creating branch ${branch} origin/${branch}"
        gitCheckoutBranchWithOrigin $branch
    done
    gitCheckout $currentBranch
}

erroCount=0
minArgsCount=1
optO=false
optC=false
optM=false

while getopts "ocm" opt; do
  case $opt in
    o)
      optO=true
      ;;
    c)
      optC=true
      ;;
    m)
      optM=true
      ;;
    \?)
        messageError "Invalid option: -$OPTARG" >&2
        messageExit
        ;;
  esac
done

removeOptionsFromArguments "$@"

if [ ${#argumentsWithoutOptions[@]} -lt $minArgsCount ]; then
    messageError "Incorrect arguments specified"
    message "Syntax: gitscan [options] {dir1} [{dir2} {dir3}...]"
    messageExit
fi

for dir in "${argumentsWithoutOptions[@]}"
do
    realDir=$(getDirOrSymlinkToDir $dir)
    if [[ $realDir != 1 ]]; then
        cd $realDir>/dev/null;
        cd ->/dev/null
        for d in `findAllGitDrectories $realDir`; do
            cd $d/.. > /dev/null
            pwd=$(pwd)
            messageHighlight "\nScanning ${PWD}"
            if [[ "$optO" = true ]]; then
                updateOriginUrl
            fi
            if [[ "$optC" = true ]]; then
                createBranches "development" "test"
            fi
            if [[ "$optM" = true ]]; then
                listAllModifiedFiles $pwd
            fi
            cd - > /dev/null
        done
    else
        messageError "Directory ${dir} does not exist"
    fi
done

messageExit
