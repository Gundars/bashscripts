#!/bin/bash 
# Merges current branch with {branch}, pushes changes to origin
# If no {branch} is specified, "development" is used
# Syntax: $ gitmerge [options] [branch]
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
ALLOWEDARGS=1
OPTP=false
PRBRANCHES=(test master)

while getopts ":p" opt; do
  case $opt in
    p)
      OPTP=true
      ALLOWEDARGS=$[ALLOWEDARGS + 1]
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ $# -gt $ALLOWEDARGS ]; then
    messageError "Received $# arguments, only ${ALLOWEDARGS} allowed!"
    message "Syntax: gitmerge [options] [branch]"
    exit 1
fi

currentBranch="$(gitGetCurrentBranch)"
mergeBranch="development"
if [[ $1 && "$OPTP" = false ]]; then 
    mergeBranch=$1
elif [[ $1 && "$OPTP" = true && $2 ]]; then 
    mergeBranch=$2
fi
message "Merging ${gConf[colorHighlight]}${currentBranch}${gConf[colorNormal]} with ${gConf[colorHighlight]}${mergeBranch}${gConf[colorNormal]}"

CHECKOUT=$((git checkout $mergeBranch) 2>&1)
if [[ "${CHECKOUT}" =~ "error: pathspec" ]]; then
    message "No such branch ${mergeBranch}. Creating..."
    git checkout -b $mergeBranch origin/$mergeBranch
    CURRENT=$((git rev-parse --abbrev-ref HEAD) 2>&1)
    if [[ "${CURRENT}" != "${mergeBranch}" ]]; then
        messageError "could not switch to ${mergeBranch}"
        exit 1
    fi
fi
git pull origin $mergeBranch
git merge --no-ff $currentBranch
git push origin $mergeBranch
git checkout $currentBranch

if [ "$OPTP" = true ] ; then
    currentOrigin=$(gitGetCurrentOrigin)
    if [[ "${currentOrigin}" =~ "x-oauth-basic" ]]; then
      cleanedOrigin=(`echo $currentOrigin | tr '@' "\n"`)
      newOrigin="https://${cleanedOrigin[1]}"
      if [[ "${newOrigin}" =~ "https://github.com/".*".git" ]] ; then
         currentOrigin=$newOrigin
      fi
    elif [[ "${currentOrigin}" =~ "git@github.com:" ]]; then
      cleanedOrigin=(`echo $currentOrigin | tr ':' "\n"`)
      newOrigin="https://github.com/${cleanedOrigin[1]}"
      if [[ "${newOrigin}" =~ "https://github.com/".*".git" ]] ; then
         currentOrigin=$newOrigin
      fi
    fi
    for prBranch in ${PRBRANCHES[@]}; do
        echo -e "${gConf[colorHighlight]}PR ${prBranch}:${gConf[colorNormal]} ${currentOrigin/%.git//compare/${prBranch}...${currentBranch}}"
    done
fi

messageExit
