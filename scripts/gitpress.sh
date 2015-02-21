#!/bin/bash 
# compresses all commits in current local branch into single commit
# Syntax: $ gitpress [options]
source ~/.bashscripts/lib/commons.sh
ALLOWEDARGS=2
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
    echo -e "${gConf[colorError]}${ERRMASCOT}ERROR: Received $# arguments, only ${ALLOWEDARGS} allowed! Syntax: gitpress [options]${gConf[colorNormal]}"
    exit 1
fi

CURRENTBRANCH="$(b=$(git symbolic-ref -q HEAD); { [ -n "$b" ] && echo ${b##refs/heads/}; } || echo HEAD)"
if [[ "$OPTF" = false ]]; then 
    for UNSAFEBRANCH in ${UNSAFEBRANCHES[@]}
    do
      if [[ ${UNSAFEBRANCH} == ${CURRENTBRANCH} ]]; then
        echo -e "${gConf[colorError]}${ERRMASCOT}ERROR: Use -f option to compress, branch name '${UNSAFEBRANCH}' is too generic${gConf[colorNormal]}"
        exit 1 
      fi
    done
fi

git reset $(git commit-tree HEAD^{tree} -m "Compress")

SAFEPUSH="git push origin +${CURRENTBRANCH}"
if [[ "$OPTP" = true ]]; then 
    $(${SAFEPUSH})
else
    echo -e "Use command '${SAFEPUSH}' to overwrite remote ${CURRENTBRANCH} branch"
fi

exit 0
