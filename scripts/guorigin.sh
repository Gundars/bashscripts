#!/bin/bash
# Update git origins from o-auth and SSH to native https in all git repos found in each of specified directories {dir}
# Syntax: $ guorigin.sh {dir1} [{dir2} {dir3}...]
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
if [ $# -lt 1 ]
  then
    echo -e "\n${gConf[colorError]}${gConf[errorMascot]}ERROR: Incorrect arguments specified${gConf[colorNormal]}"
    echo "Usage: guorigin {dir1} [{dir2} {dir3}...]"   
    exit 0
fi

directories="${@:1}";

for dir in $directories
do
    if [ -d "$dir" ]; then    
        cd $dir>/dev/null;
        echo -e "\nScanning ${PWD}";
        cd ->/dev/null

        for d in `find $dir -name .git -type d`; do
            cd $d/.. > /dev/null
            echo -e "\n${gConf[colorHighlight]}Updating `pwd`${gConf[colorNormal]}"
            CURRENT=`git config --get remote.origin.url`;
            echo -e "Current Origin: ${CURRENT}"
            FILTERBY="x-oauth-basic"
            FILTERBYSSH="git@github.com:"
            if [[ "${CURRENT}" =~ "${FILTERBY}" ]]; then
                STR_ARRAY=(`echo $CURRENT | tr '@'  "\n"`)
                NEW="https://${STR_ARRAY[1]}"
                if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
                    `git remote set-url origin "${NEW}"`
                    NEWCHANGED=`git config --get remote.origin.url`;
                    if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                        echo -e "${gConf[colorSuccess]}Origin changed to ${NEWCHANGED}${gConf[colorNormal]}"
                    else
                        ERRCOUNT=$[ERRCOUNT + 1]
                        echo -e "${gConf[colorError]}ERROR: could not change origin${gConf[colorNormal]}"
                    fi
                else
                    ERRCOUNT=$[ERRCOUNT + 1]
                    echo -e "${gConf[colorError]}ERROR: ${NEW} is not a valid repository${gConf[colorNormal]}"
                fi
            elif [[ "${CURRENT}" =~ "${FILTERBYSSH}" ]]; then
                STR_ARRAY=(`echo $CURRENT | tr ':'  "\n"`)
                NEW="https://github.com/${STR_ARRAY[1]}"
                if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
                    `git remote set-url origin "${NEW}"`
                    NEWCHANGED=`git config --get remote.origin.url`;
                    if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                        echo -e "${gConf[colorSuccess]}Origin changed to ${NEWCHANGED}${gConf[colorNormal]}"
                    else
                        ERRCOUNT=$[ERRCOUNT + 1]
                        echo -e "${gConf[colorError]}ERROR: could not change origin${gConf[colorNormal]}"
                    fi
                else
                    ERRCOUNT=$[ERRCOUNT + 1]
                    echo -e "${gConf[colorError]}ERROR: ${NEW} is not a valid repository${gConf[colorNormal]}"
                fi
            else
                echo -e "Origin OK"
            fi
            cd - > /dev/null
        done
    else
        echo -e "\n${gConf[colorError]}${gConf[errorMascot]}\nERROR: Directory $dir does not exist ${gConf[colorNormal]}"
    fi
done

if [[ "${ERRCOUNT}" == "0" ]] ; then
    finalcol=${gConf[colorSuccess]}
else
    finalcol=${gConf[colorError]}
fi

echo -e "\n${finalcol}Completed with ${ERRCOUNT} errors${gConf[colorNormal]}"
