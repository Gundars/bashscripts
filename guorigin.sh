#!/bin/bash

# Update origins in /home/vagrant/sites/fusion.dev/docs/wp-content/plugins/

HIGHLIGHT="\e[01;34m"
NORMAL='\e[00m'
ERROR='\033[31m'
GREEN='\e[32m'

DIR="/fill/this/in/..........";
cd $DIR>/dev/null; echo -e "${HIGHLIGHT}Scanning ${PWD}${NORMAL}"; cd ->/dev/null

for d in `find $DIR -name .git -type d`; do
  cd $d/.. > /dev/null
  echo -e "\n${HIGHLIGHT}Updating `pwd`$NORMAL"
  CURRENT=`git config --get remote.origin.url`;
  echo -e "Current Origin $NORMAL: ${CURRENT}"
  FILTERBY="x-oauth-basic"
  if [[ "${CURRENT}" =~ "${FILTERBY}" ]]; then
    #echo "Origin needs cleanup"
    STR_ARRAY=(`echo $CURRENT | tr '@'  "\n"`)
    NEW="https://${STR_ARRAY[1]}"
    if [[ "${NEW}" =~ "https://github.com/discovery-fusion/".*".git" ]] ; then
        #echo "Link ok"
        `git remote set-url origin "${NEW}"`
        NEWCHANGED=`git config --get remote.origin.url`;
        if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
            echo -e "${GREEN}Origin changed to ${NEWCHANGED}"
        else
            echo -e "${ERROR}ERROR: could not change origin"
        fi
    else
        echo -e "${ERROR}ERROR: ${NEW} is not a valid fusion platform repo"
    fi
  else
    echo -e "${GREEN}Origin is fine"
  fi

  cd - > /dev/null
done
