#!/bin/bash
# Scan all directories {dir} for git repositories and perform actions based on options
# Syntax: $ gitscan [options] {dir1} [{dir2} {dir3}...]
# Options:
# -o update remote origin links from oauth/ssh to https://
# -m list all modified files
# -c create branches in sync with origin
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
ALLOWEDARGS=0
OPTO=false
OPTC=false
OPTM=false

while getopts "ocm" opt; do
  case $opt in
    o)
      OPTO=true
      ALLOWEDARGS=$[ALLOWEDARGS + 1]
      ;;
    c)
      OPTC=true
      ALLOWEDARGS=$[ALLOWEDARGS + 1]
      ;;
    m)
      OPTM=true
      ALLOWEDARGS=$[ALLOWEDARGS + 1]
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done


if [ $# -lt $ALLOWEDARGS ]
  then
    messageError "Incorrect arguments specified"
    message "Usage: gitscan [options] {dir1} [{dir2} {dir3}...]"
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

            # OPT -o
            if [[ "$OPTO" = false ]]; then
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
            fi

            # OPT -c
            if [[ "$OPTC" = false ]]; then

            fi

            # OPT -m
            if [[ "$OPTM" = false ]]; then

            fi
            
            cd - > /dev/null
        done
    else
        messageError "Directory ${dir} does not exist"
    fi
done

messageExit

