#!/bin/bash
# Checks out and pulls specified {branch} in all git repos found in each of specified {dir}
# Syntax: $ gcobranch.sh {branch} {dir1} [{dir2} {dir3}...]

CNORMAL='\e[00m'
CHIGHLIGHT="\e[01;36m"
CERROR='\033[31m'
CSUCCESS='\e[32m'
ERRMASCOT='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_|';
ERRCOUNT=0
CHANGPENDING=''
# ERRCOUNT=$[ERRCOUNT + 1]
if [ $# -lt 1 ]
  then
    echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Incorrect arguments specified${CNORMAL}"
    echo "Usage: git-check-status [dir] [dir]..."   
    exit 0
fi

directories="${@:1}";

for dir in $directories
do
    if [ -d "$dir" ]; then    
        cd $dir>/dev/null;
        echo -e "Scanning ${PWD}";
        cd ->/dev/null

        for d in `find $dir -name .git -type d`; do
          cd $d/.. > /dev/null
            CHANGE=`git status --porcelain`

			if [ -n "$CHANGE" ]; then
			 PWD=`pwd `
			 echo -e "\n${CHIGHLIGHT}${PWD}"
			 echo -e "\n${CERROR}${CHANGE}"

			fi
          cd - > /dev/null
        done
    else
        echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Directory $dir does not exist ${CNORMAL}"
    fi
done
