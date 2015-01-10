#!/bin/bash
# Change build number on environmnet
# Syntax: $ buildenv {env} {branch} {build number}
# Enabled environmnets: www_dplay_nl
# Enabled branches: dev, test

ENV=www_dplay_nl
BRANCH=dev
BNR=666
TMPDIR=~/.bashscripts/tmp

rm -rf $TMPDIR
git clone https://github.com/DNI-New-Platform/fusion_enriched_site_definition.git $TMPDIR
FILE=$TMPDIR/environment_definition/${BRANCH}1/environment_definition.def
sed -i "s/^${ENV}.*/${ENV} = ${BNR}/g" $FILE
git add $FILE
git diff $FILE
git commit -m "${ENV} changed to ${BNR}"
git push origin master
rm -rf $TMPDIR