#!/bin/bash 
# Merges current branch with {branch}, pushes changes to origin
# If no {branch} is specified, "development" is used
# Syntax: $ gitmerge [options] [branch]
source ~/.bashscripts/lib/commons.sh

erroCount=0
optP=false
prBranches=(test master)

while getopts ":p" opt; do
  case $opt in
    p)
      optP=true
      ;;
    \?)
        messageError "Invalid option: -$OPTARG" >&2
        messageExit
      ;;
  esac
done

currentBranch="$(gitGetCurrentBranch)"
mergeBranch="development"
if [[ $1 && "$optP" = false ]]; then 
    mergeBranch=$1
elif [[ $1 && "$optP" = true && $2 ]]; then 
    mergeBranch=$2
fi
message "Merging ${gConf[colH]}${currentBranch}${gConf[colN]} with ${gConf[colH]}${mergeBranch}${gConf[colN]}"

gitCheckoutBranchWithOrigin $mergeBranch
currentBranch=$(gitGetCurrentBranch)
if [[ "${currentBranch}" != "${mergeBranch}" ]]; then
    messageExit
fi

git pull origin $mergeBranch
git merge --no-ff $currentBranch
git push origin $mergeBranch
git checkout $currentBranch

if [ "$optP" = true ] ; then
   origin=$(gitOriginAnyToHttps)
   message "\n"
    for prBranch in ${prBranches[@]}; do
        message "${gConf[colH]}PR ${prBranch}:${gConf[colN]} ${origin/%.git//compare/${prBranch}...${currentBranch}}"
    done
fi

messageExit
