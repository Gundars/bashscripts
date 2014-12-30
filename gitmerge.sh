#!/bin/bash 
# Merges current branch with development or {branch}, pushes to origin development,
# creates PR links for test and master
# Syntax: $ gitmerge {branch}

CNORMAL='\e[00m'
CHIGHLIGHT="\e[01;36m"
CERROR='\033[31m'
CSUCCESS='\e[32m'
ERRMASCOT='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_|';
ERRCOUNT=0

currentBranch="$(b=$(git symbolic-ref -q HEAD); { [ -n "$b" ] && echo ${b##refs/heads/}; } || echo HEAD)"
mergeBranch="development"
if [ $1 ]; then 
    mergeBranch=$1
fi
echo -e "Merging ${CHIGHLIGHT}${currentBranch}${CNORMAL} with ${CHIGHLIGHT}${mergeBranch}${CNORMAL}";

git checkout $mergeBranch
git pull origin $mergeBranch
git merge --no-ff $currentBranch
git push origin $mergeBranch
git checkout $mergeBranch


