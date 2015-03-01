#!/bin/bash
# Change build number on environmnet
# Syntax: $ buildenv {env} {branch} {build number}
# { env} syntax: www_domain_extension
# {branch} syntax: dev | test | staging
# {build number} syntax: integer 1-5 digits long
source ~/.bashscripts/lib/commons.sh

ERRCOUNT=0
ALLOWEDARGS=3
ENV=$1
BRANCH=$2
BNR=$3
ENVREGEX="^w{3}_.*_[a-zA-Z]{2,4}$"
BRANCHREGEX="^(dev|test|staging)$"
BNRREGEX="[0-9]{1,5}"

if [ $# -lt $ALLOWEDARGS ]; then
    messageError "Incorrect arguments specified"
    echo "Syntax: buildenv {env} {branch} {build number}"
    echo "{env} syntax: www_domain_extension"
    echo "{branch} syntax: dev | test | staging"
    messageExit
fi

if ! [[ $ENV =~ $ENVREGEX ]]; then
	messageError "Bad environment"
	message "{env} syntax: www_domain_extension"
fi

if ! [[ $BRANCH =~ $BRANCHREGEX ]]; then
	messageError "Bad branch"
	message "{branch} syntax: dev | test | staging"
fi

if ! [[ $BNR =~ $BNRREGEX ]]; then
	messageError "Bad build number"
	message "{build number} syntax: integer 1-5 digits long"
fi

if [[ uConf[enrichedRepository] =~ "https/link/to/encriched.git" ]]; then
	messageError "Bad repository name"
	message "Please change line 4 'https/link/to/encriched.git' in file ~/.bashscripts/config/user.sh to valid link to enriched github repository"
fi

if ! [[ $ERRCOUNT =~ 0 ]]; then
    messageExit
fi

if ! [ -d gConf[dirTmp] ]; then
    git clone uConf[enrichedRepository] gConf[dirTmp]
fi
cd gConf[dirTmp]
git pull origin master
FILE=environment_definition/${BRANCH}1/environment_definition.def
if ! [ -f $FILE ]; then
    messageError "File ${FILE} does not exist"
    messageExit
fi
sed -i "s/^${ENV}.*/${ENV} = ${BNR}/g" $FILE
git add $FILE
git commit -m "${ENV} to ${BNR}"
DIFFG=`git diff HEAD^ HEAD --color=always|perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/'`
DIFFR=`git diff HEAD^ HEAD --color=always|perl -wlne 'print $1 if /^\e\[31m-(.*)\e\[m$/'`
git push origin master
cd gConf[dirStart]
echo -e "\n${gConf[colorError]} ${DIFFR} ${gConf[colorNormal]}"
echo -e "${gConf[colorSuccess]} ${DIFFG} ${gConf[colorNormal]}"

messageExit
