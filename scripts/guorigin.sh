#!/bin/bash
# Update git origins from o-auth and SSH to native https in all git repos found in each of specified directories {dir}
# Syntax: $ guorigin.sh {dir1} [{dir2} {dir3}...]
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
if [ $# -lt 1 ]
  then
    messageError "Incorrect arguments specified"
    message "Usage: guorigin {dir1} [{dir2} {dir3}...]"   
    exit 1
fi

directories="${@:1}";
for dir in $directories
do
    if [ -d "$dir" ]; then    
        cd $dir>/dev/null;
        cd ->/dev/null
        for d in `findAllGitDrectories $dir`; do
            cd $d/.. > /dev/null
            messageHighlight "\nUpdating ${PWD}"
            CURRENT=$(gitGetCurrentOrigin)
            echo -e "Current Origin: ${CURRENT}"
            FILTERBY="x-oauth-basic"
            FILTERBYSSH="git@github.com:"
            if [[ "${CURRENT}" =~ "${FILTERBY}" ]]; then
                STR_ARRAY=(`echo $CURRENT | tr '@'  "\n"`)
                NEW="https://${STR_ARRAY[1]}"
                if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
                    gitSetCurrentOrigin $NEW
                    NEWCHANGED=$(gitGetCurrentOrigin)
                    if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                        messageSuccess "Origin changed to ${NEWCHANGED}"
                    else
                        messageError "unable to change origin"
                    fi
                else
                    messageError "${NEW} is not a valid repository"
                fi
            elif [[ "${CURRENT}" =~ "${FILTERBYSSH}" ]]; then
                STR_ARRAY=(`echo $CURRENT | tr ':'  "\n"`)
                NEW="https://github.com/${STR_ARRAY[1]}"
                if [[ "${NEW}" =~ "https://github.com/".*".git" ]] ; then
                    gitSetCurrentOrigin $NEW
                    NEWCHANGED=$(gitGetCurrentOrigin)
                    if [[ "${NEW}" =~ ${NEWCHANGED} ]] ; then
                        messageSuccess "Origin changed to ${NEWCHANGED}"
                    else
                        messageError "unable to change origin"
                    fi
                else
                    messageError "${NEW} is not a valid repository"
                fi
            else
                message "Origin OK"
            fi
            cd - > /dev/null
        done
    else
        messageError "Directory ${dir} does not exist"
    fi
done

messageExit
exit 0
