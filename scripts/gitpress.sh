#!/bin/bash 
# compresses all commits in current local branch into single commit
# Syntax: $ gitpress [options]
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
ALLOWEDARGS=0
OPTF=false
OPTP=false
UNSAFEBRANCHES=(development test master)

while getopts ":fp" opt; do
  case $opt in
    f)
      OPTF=true
      ALLOWEDARGS=$[ALLOWEDARGS + 1]
      ;;
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
    message "Syntax: gitpress [options]"
    exit 1
fi

CURRENTBRANCH="$(gitGetCurrentBranch)"
if [[ "$OPTF" = false ]]; then 
    for UNSAFEBRANCH in ${UNSAFEBRANCHES[@]}
    do
      if [[ ${UNSAFEBRANCH} == ${CURRENTBRANCH} ]]; then
        messageError "Use -f option to compress, branch name '${UNSAFEBRANCH}' is too generic"
        exit 1 
      fi
    done
fi

git reset $(git commit-tree HEAD^{tree} -m "Compress")

SAFEPUSH="git push origin +${CURRENTBRANCH}"
if [[ "$OPTP" = true ]]; then 
    $(${SAFEPUSH})
else
    message "Use command '${SAFEPUSH}' to overwrite remote ${CURRENTBRANCH} branch"
fi

messageExit

