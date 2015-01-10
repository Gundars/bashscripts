#!/bin/bash
# Change build number on environmnet
# Syntax: $ buildenv {env} {branch} {build number}
# {env} syntax: www_domain_extension
# {branch} syntax: dev | test | staging
# {build number} syntax: integer 1-5 digits long

CNORMAL='\e[00m'
CHIGHLIGHT="\e[01;36m"
CERROR='\033[31m'
CSUCCESS='\e[32m'
ENV=$1
ENVREGEX="^w{3}_.*_[a-zA-Z]{2,4}$"
BRANCH=$2
BRANCHREGEX="^(dev|test|staging)$"
BNR=$3
BNRREGEX="[0-9]{1,5}"
TMPDIR=~/.bashscripts/tmp
ERRMASCOT='            __\n           / _)\n    .-^^^-/ /\n __/       /\n<__.|_|-|_|';
ERRCOUNT=0

if [ $# -lt 3 ]; then
  	ERRCOUNT=$[ERRCOUNT + 1]
    echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Incorrect arguments specified${CNORMAL}\n"
    echo "Usage: buildenv {env} {branch} {build number}"
    echo "{env} syntax: www_domain_extension"
    echo "{branch} syntax: dev | test | staging"
    echo -e "\n${CERROR}Exited with ${ERRCOUNT} errors${CNORMAL}"
    exit 0
fi

if ! [[ $ENV =~ $ENVREGEX ]]; then
	ERRCOUNT=$[ERRCOUNT + 1]
	echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Bad environment${CNORMAL}\n"
	echo "{env} syntax: www_domain_extension"
	echo -e "\n${CERROR}Exited with ${ERRCOUNT} errors${CNORMAL}"
fi

if ! [[ $BRANCH =~ $BRANCHREGEX ]]; then
	ERRCOUNT=$[ERRCOUNT + 1]
	echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Bad branch${CNORMAL}\n"
	echo "{branch} syntax: dev | test | staging"
	echo -e "\n${CERROR}Exited with ${ERRCOUNT} errors${CNORMAL}"
fi

if ! [[ $BNR =~ $BNRREGEX ]]; then
	ERRCOUNT=$[ERRCOUNT + 1]
	echo -e "\n${CERROR}${ERRMASCOT}\nERROR: Bad build number${CNORMAL}\n"
	echo "{build number} syntax: integer 1-5 digits long"
	echo -e "\n${CERROR}Exited with ${ERRCOUNT} errors${CNORMAL}"
fi

rm -rf $TMPDIR
git clone https://github.com/DNI-New-Platform/fusion_enriched_site_definition.git $TMPDIR
FILE=$TMPDIR/environment_definition/${BRANCH}1/environment_definition.def
sed -i "s/^${ENV}.*/${ENV} = ${BNR}/g" $FILE
git add $FILE
git diff $FILE
git commit -m "${ENV} changed to ${BNR}"
git push origin master
rm -rf $TMPDIR
