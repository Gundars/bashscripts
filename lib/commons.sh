#!/bin/bash
# Container of all common functions
source ~/.bashscripts/config/global.sh
source ~/.bashscripts/config/user.sh

function message {
	if [ -z "$1" ]; then
		echo "message param 1 error"
	else
	   echo -e "$1"       
	fi	
}

function messageSuccess {
	if [ -z "$1" ]; then
		echo "messageSuccess param 1 error"
	else
	   echo -e "${gConf[colorSuccess]}$1${gConf[colorNormal]}"       
	fi	
}

function messageHighlight {
	if [ -z "$1" ]; then
		echo "messageHightlight param 1 error"
	else
	   echo -e "${gConf[colorHighlight]}$1${gConf[colorNormal]}"       
	fi	
}

function messageError {
	ERRCOUNT=$[ERRCOUNT + 1]
	if [ -z "$1" ]; then
		echo "messageError param 1 error"
	else
		if [ "$2" == false ]; then
			local em=''
			local er='\n'
		else
			local em=${gConf[errorMascot]}
			local er='ERROR: '
		fi
		echo -e "${gConf[colorError]}${em}${er}$1${gConf[colorNormal]}"
	fi
}

function messageExit {
	if [[ "${ERRCOUNT}" == "0" ]] ; then
    	messageSuccess "Completed without errors"
    	exit 0
	else
	    messageError "Completed with ${ERRCOUNT} errors" false
	    exit 1
	fi
}

function gitGetCurrentOrigin {
	git config --get remote.origin.url
}

function gitSetCurrentOrigin {
	if [ -z "$1" ]; then
		echo "gitSetCurrentOrigin param 1 error"
	else
		git remote set-url origin $1
	fi
}

function gitGetCurrentBranch {
	$(b=$(git symbolic-ref -q HEAD); { [ -n "$b" ] && echo ${b##refs/heads/}; } || echo HEAD)
}

function findAllGitDrectories {
	find $1 -name .git -type d
}

function gitFetchAll {
    git fetch --all
}