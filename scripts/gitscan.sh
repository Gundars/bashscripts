#!/bin/bash
# Scan all directories {dir} for git repositories and perform actions based on options
# Syntax: $ gitscan [options] {dir1} [{dir2} {dir3}...]
# Options:
# -o update remote origin links from oauth/ssh to https://
# -m list all modified files
# -c create test and development branches in sync with origin
source ~/.bashscripts/lib/commons.sh

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

removeOptionsFromArguments ${@:1}

if [ ${#argumentsWithoutOptions[@]} -lt $minArgsCount ]; then
    messageError "Incorrect arguments specified"
    message "Syntax: gitscan [options] {dir1} [{dir2} {dir3}...]"
    messageExit
fi

for dir in $argumentsWithoutOptions
do
    if [ -d "$dir" ]; then    
        cd $dir>/dev/null;
        cd ->/dev/null
        for d in `findAllGitDrectories $dir`; do
            cd $d/.. > /dev/null
            pwd=$(pwd)
            messageHighlight "\nScanning ${PWD}"
            if [[ "$optO" = true ]]; then
                updateOriginLinks
            fi
            if [[ "$optC" = true ]]; then
                createBranches 'development' 'test'
            fi
            if [[ "$optM" = true ]]; then
                listAllModifiedFiles $PWD
            fi
            cd - > /dev/null
        done
    else
        messageError "Directory ${dir} does not exist"
    fi
done

messageExit

#===============================================================

function updateOriginLinks {
    CURRENT=$(gitGetCurrentOrigin)
    echo -e "Current Origin: ${CURRENT}"
    FILTERBY="x-oauth-basic"
    FILTERBYSSH="git@github.com:"
    if [[ "${CURRENT}" =~ "${FILTERBY}" ]]; then
        STR_ARRAY=(`echo $CURRENT | tr '@'  "\n"`)
        NEW="https://${STR_ARRAY[1]}"
        if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
            gitSetCurrentOrigin $NEW
            NEWCHANGED=$(gitGetCurrentOrigin)
            if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                messageSuccess "Origin changed to ${NEWCHANGED}"
            else
                messageError "unable to change origin"
            fi
        else
            messageError "${NEW} is not a valid repository"
        fi
    elif [[ "${CURRENT}" =~ "${FILTERBYSSH}" ]]; then
        STR_ARRAY=(`echo $CURRENT | tr ':'  "\n"`)
        NEW="https://github.com/${STR_ARRAY[1]}"
        if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
            gitSetCurrentOrigin $NEW
            NEWCHANGED=$(gitGetCurrentOrigin)
            if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                messageSuccess "Origin changed to ${NEWCHANGED}"
            else
                messageError "unable to change origin"
            fi
        else
            messageError "${NEW} is not a valid repository"
        fi
    else
        message "Origin OK"
    fi
}

function listAllModifiedFiles {
    MODIFIED=`git status --porcelain`
    if [ -n "$MODIFIED" ]; then
        messageHighlight "\nModified files found in ${1}"
        message $MODIFIED
    fi
}

function createBranches {
    CURRENT=$(gitGetCurrentOrigin)
    git checkout master
    gitFetchAll
    branches=${@:1};
    for branch in $branches
    do
        BRANCHLOCAL=$(git branch | grep "${branch}" | tr -d '* ')
        BRANCHORIGIN=$(git branch -r | grep -w 'origin/${branch}' | tr -d "  origin/")
        if [[ "${BRANCHLOCAL}" != "" && "${BRANCHORIGIN}" != '${branch}' ]]; then
             message "Creating branch ${branch} origin/${branch}"
             $(git checkout -b ${branch} origin/${branch})
        fi
    done
}
