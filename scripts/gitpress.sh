#!/bin/bash 
# compresses all commits in current local branch into single commit
# Syntax: $ gitpress [options]
source ~/.bashscripts/lib/commons.sh

erroCount=0
maxArgsCount=0
optF=false
optP=false
unsafeBranches=(development test master)

while getopts ":fp" opt; do
  case $opt in
    f)
      optF=true
      maxArgsCount=$[maxArgsCount + 1]
      ;;
    p)
      optP=true
      maxArgsCount=$[maxArgsCount + 1]
      ;;
    \?)
        messageError "Invalid option: -$OPTARG" >&2
        messageExit
      ;;
  esac
done

if [ $# -gt $maxArgsCount ]; then
    messageError "Received $# arguments, only ${allowedArgsCount} allowed!"
    message "Syntax: gitpress [options]"
    exit 1
fi

currentBranch="$(gitGetCurrentBranch)"
if [[ "$optF" = false ]]; then 
    for unsafeBranche in ${unsafeBranches[@]}
    do
      if [[ ${unsafeBranche} == ${currentBranch} ]]; then
        messageError "Use -f option to compress, branch name '${unsafeBranche}' is too generic"
        exit 1 
      fi
    done
fi

git reset $(git commit-tree HEAD^{tree} -m "Compress")

safePush="git push origin +${currentBranch}"
if [[ "$optP" = true ]]; then 
    $(${safePush})
else
    message "Use command '${safePush}' to overwrite remote ${currentBranch} branch"
fi

messageExit

