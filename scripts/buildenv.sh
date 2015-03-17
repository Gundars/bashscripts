#!/bin/bash
# Change build number on environmnet
# Syntax: $ buildenv {env} {branch} {build number}
# { env} syntax: www_domain_extension
# {branch} syntax: dev | test | staging
# {build number} syntax: integer 1-5 digits long
source ~/.bashscripts/lib/commons.sh

erroCount=0
minArgsCount=3
env=$1
envRegex="^w{3}_.*_[a-zA-Z]{2,4}$"
branch=$2
branchRegex="^(dev|test|staging)$"
buildNo=$3
buildNoRegex="[0-9]{1,5}"

if [ $# -lt $minArgsCount ]; then
    messageError "Incorrect arguments specified"
    message  "Syntax: buildenv {env} {branch} {build number}"
    message "{env} syntax: www_domain_extension"
    message "{branch} syntax: dev | test | staging"
    messageExit
fi

if ! [[ $env =~ $envRegex ]]; then
	messageError "Bad environment"
	message "{env} syntax: www_domain_extension"
fi

if ! [[ $branch =~ $branchRegex ]]; then
	messageError "Bad branch"
	message "{branch} syntax: dev | test | staging"
fi

if ! [[ $buildNo =~ $buildNoRegex ]]; then
	messageError "Bad build number"
	message "{build number} syntax: integer 1-5 digits long"
fi

if [[ uConf[enrichedRepository] =~ "https/link/to/encriched.git" ]]; then
	messageError "Bad repository name"
	message "Please change line 4 'https/link/to/encriched.git' in file ~/.bashscripts/config/user.sh to valid link to enriched github repository"
fi

exitIfErrors

if ! [ -d ${gConf[dirTmp]} ]; then
    git clone ${uConf[enrichedRepository]} ${gConf[dirTmp]}
fi
cd ${gConf[dirTmp]}
git pull origin master
FILE=environment_definition/${branch}1/environment_definition.def
if ! [ -f $FILE ]; then
    messageError "File ${FILE} does not exist"
    messageExit
fi
sed -i "s/^${env}.*/${env} = ${buildNo}/g" $FILE
git add $FILE
git commit -m "${env} to ${buildNo}"
git push origin master
cd ${gConf[dirStart]}
message "\n${gConf[colE]} ${gitDiffDeleted} ${gConf[colN]}"
message "${gConf[colS]} ${gitDiffAdded} ${gConf[colN]}"

messageExit
