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
	   echo -e "${gConf[colS]}$1${gConf[colN]}"
	fi	
}

function messageHighlight {
	if [ -z "$1" ]; then
		echo "messageHightlight param 1 error"
	else
	   echo -e "${gConf[colH]}$1${gConf[colN]}"
	fi	
}

function messageError {
	erroCount=$[erroCount + 1]
	if [ -z "$1" ]; then
		echo "messageError param 1 error"
	else
		if [ "$2" == false ]; then
			local em=''
			local er='\n'
		else
			local em=$(getRandomErrorMascot)
			local er='ERROR: '
		fi
		echo -e "${gConf[colE]}${em}${er}$1${gConf[colN]}"
	fi
}

function messageExit {
    message "\n"
    if [[ "${erroCount}" == "0" ]] ; then
    	messageSuccess "Completed without errors"
    	exit 0
	else
	    messageError "Completed with ${erroCount} errors" false
	    exit 1
	fi
}

function exitIfErrors {
    if ! [[ $erroCount =~ 0 ]]; then
        messageExit
    fi
}

#pass an array of all orginal args except 0 !
function removeOptionsFromArguments {
    argumentsWithoutOptions=()
    for arg in "$@"
    do
        if [[ ${arg:0:1} != "-"  ]]; then
            argumentsWithoutOptions+=($arg)
        fi
    done
}

function gitGetCurrentOrigin {
	git config --get remote.origin.url
}

function gitSetCurrentOrigin {
    git remote set-url origin $1
}

function gitGetCurrentBranch {
	#$(b=$(git symbolic-ref -q HEAD); { [ -n "$b" ] && echo ${b##refs/heads/}; } || echo HEAD)
	git rev-parse --abbrev-ref HEAD 2>&1
}

function findAllGitDrectories {
	find $1 -name .git -type d
}

function gitFetchAll {
    local a=$((git fetch --all) 2>&1)
}

function gitCheckout {
     local a=$((git checkout $1) 2>&1)
}
function gitOriginAnyToHttps {
    local currentOrigin=$(gitGetCurrentOrigin)
    if [[ "${currentOrigin}" =~ "x-oauth-basic" ]]; then
      local cleanedOrigin=(`echo $currentOrigin | tr '@' "\n"`)
      local newOrigin="https://${cleanedOrigin[1]}"
      if [[ "${newOrigin}" =~ "https://github.com/".*".git" ]] ; then
         local currentOrigin=$newOrigin
      fi
    elif [[ "${currentOrigin}" =~ "git@github.com:" ]]; then
      local cleanedOrigin=(`echo $currentOrigin | tr ':' "\n"`)
      local newOrigin="https://github.com/${cleanedOrigin[1]}"
      if [[ "${newOrigin}" =~ "https://github.com/".*".git" ]] ; then
         local currentOrigin=$newOrigin
      fi
    fi

    echo $currentOrigin
}

function gitDiffDeleted {
    git diff HEAD^ HEAD --color=always|perl -wlne 'print $1 if /^\e\[32m\+\e\[m\e\[32m(.*)\e\[m$/'
}

function gitDiffAdded {
    git diff HEAD^ HEAD --color=always|perl -wlne 'print $1 if /^\e\[31m-(.*)\e\[m$/'
}

function gitCheckoutBranchWithOrigin {
    local branchToCheckout=$1
    checkout=$((git checkout $branchToCheckout) 2>&1)
    if [[ "${checkout}" =~ "error: pathspec" ]]; then
        message "No such branch ${branchToCheckout}. Creating..."
        $((git checkout -b $branchToCheckout origin/$branchToCheckout) &> /dev/null)
        currentBranch=$(gitGetCurrentBranch)
        if [[ "${currentBranch}" != "${branchToCheckout}" ]]; then
            $((git fetch --all) &> /dev/null)
            $((git fetch origin $mergeBranch:branchToCheckout) &> /dev/null)
            currentBranch=$(gitGetCurrentBranch)
            if [[ "${currentBranch}" != "${branchToCheckout}" ]]; then
                messageError "Branch ${branchToCheckout} does not exist in origin"
            fi
        fi
    fi
}

function gitLastCommit {
    local lc=$((git log -n 1 --pretty=format:"%H, %cn : %s") 2>&1)
    echo $lc
}

function getRandomErrorMascot {
    printf $'%s' "${errorMascots[$(($(rand "${#errorMascots[*]}")+1))]}"
}

function rand {
	printf $((  $1 *  RANDOM  / 32767   ))
}