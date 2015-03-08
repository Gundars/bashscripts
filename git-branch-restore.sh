#!/bin/bash
# Restore mising test and development branches in repos founded in dirs
# Syntax: $ <>.sh {dir1} [{dir2} {dir3}...

CNORMAL='\e[00m'
CHIGHLIGHT="\e[01;36m"
CERROR='\033[31m'
CSUCCESS='\e[32m'
ERRMASCOT='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_|';
ERRCOUNT=0

if [ $# -lt 1 ]; then
  echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Incorrect arguments specified${CNORMAL}"
  echo "Usage: gcobranch [branch] [dir] [dir]..."   
  exit 0
fi

directories="${@:1}";
echo $directories

for dir in $directories do
  if [ -d "$dir" ]; then    
    cd $dir>/dev/null;
    echo -e "Scanning ${PWD}";
    cd ->/dev/null

    for d in `find $dir -name .git -type d`; do
      cd $d/.. > /dev/null
      echo -e "\n${CHIGHLIGHT}Repo: `pwd`$CNORMAL"
      CURRENT=`git rev-parse --abbrev-ref HEAD`;
      git checkout master 
      git fetch --all

      TESTBR=`git branch | grep  "test" | tr -d '* '`
      DEVBR=`git branch | grep  "development" | tr -d '* '`

      RTESTBR=`git branch -r | grep -w 'origin/test' | tr -d "  origin/"` 
      RDEVBR=`git branch -r | grep -w 'origin/development' | tr -d "  origin/"`

      echo -e "===Current branch$CNORMAL: ${CURRENT}"
      echo -e "===Test: (${TESTBR}) on remote (${RTESTBR})"
      echo -e "===Dev : (${DEVBR}) on remote (${RDEVBR})" 

      if [[ "${RTESTBR}" != "" ]]; then
        if  [[ "${TESTBR}" != 'test' ]]; then
        echo -e "Creating local Test"
        git checkout -b test origin/test
        fi
      fi

      if [[ "${RDEVBR}" != "" ]]; then
        if [[ "${DEVBR}" != 'development' ]]; then
          echo -e "Creating local Development"
          git checkout -b development origin/development
        fi
      fi

      cd - > /dev/null
    done
  else
  echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Directory $dir does not exist ${CNORMAL}"
  fi
done

if [[ "${ERRCOUNT}" == "0" ]] ; then
  finalcol=${CSUCCESS}
else
  finalcol=${CERROR}
fi

echo -e "\n${finalcol}Done with ${ERRCOUNT} errors${CNORMAL}"
