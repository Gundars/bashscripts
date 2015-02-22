#!/bin/bash
# Checks out and pulls specified {branch} in all git repos found in each of specified {dir}
# Syntax: $ gcobranch.sh {branch} {dir1} [{dir2} {dir3}...]
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0

if [ $# -lt 2 ]
  then
    echo -e "\n${gConf[colorError]}${ERRMASCOT}\nERROR: Incorrect arguments specified${gConf[colorNormal]}"
    echo "Syntax: gcobranch [branch] [dir] [dir]..."   
    exit 0
fi

branch=$1
directories="${@:2}";

for dir in $directories
do
    if [ -d "$dir" ]; then    
        cd $dir>/dev/null;
        echo -e "Scanning ${PWD}";
        cd ->/dev/null

        for d in `find $dir -name .git -type d`; do
          cd $d/.. > /dev/null
          echo -e "\n${gConf[colorHighlight]}Repo: `pwd`$gConf[colorNormal]"
          CURRENT=`git rev-parse --abbrev-ref HEAD`;
          echo -e "Current branch$gConf[colorNormal]: ${CURRENT}"
          TXTCHECKOUT="No need to checkout"

          if [[ "${CURRENT}" != "${branch}" ]]; then
            TXTCHECKOUT=$((git checkout $branch) 2>&1);
            if [[ "${TXTCHECKOUT}" =~ 'did not match any file' ]]; then
                echo "Creating new branch $branch";
                TXTCHECKOUT=$((git checkout -b $branch origin/$branch) 2>&1);
            fi
          else
            lcommit=`git log -n 1 --pretty=format:"%H, %cn : %s"`;
            echo -e "Already on ${branch}"
            echo -e "Last commit: ${lcommit}"
          fi

          TXTPULL=$((git pull origin $branch) 2>&1);
          NEWCHANGED=`git rev-parse --abbrev-ref HEAD`;
          if [[ "${branch}" == ${NEWCHANGED} ]] ; then
              echo -e "${gConf[colorSuccess]}${NEWCHANGED} checked out & pulled"
          else
              ERRCOUNT=$[ERRCOUNT + 1]
              echo -e "\n${gConf[colorError]}${ERRMASCOT}\nERROR: could not check out ${branch}"
              echo -e "${gConf[colorHighlight]}Checkout output:${gConf[colorNormal]}\n ${TXTCHECKOUT} \n${gConf[colorHighlight]}Pull output:${gConf[colorNormal]} ${TXTPULL}"
          fi

          cd - > /dev/null
        done
    else
        echo -e "\n${gConf[colorError]}${ERRMASCOT}\nERROR: Directory $dir does not exist ${gConf[colorNormal]}"
    fi
done

if [[ "${ERRCOUNT}" == "0" ]] ; then
    finalcol=${gConf[colorSuccess]}
else
    finalcol=${gConf[colorError]}
fi

echo -e "\n${finalcol}Done with ${ERRCOUNT} errors${gConf[colorNormal]}"


