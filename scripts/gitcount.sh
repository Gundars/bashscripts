#!/bin/bash
# generate your Github Token @ https://github.com/settings/tokens/new  with "repo" access
apiToken=77885...........
apiRoot=https://api.github.com
owner=discovery-fusion
repos=(fusion-api-user fusion-lib-payment fusion-subscription fusion-account-management fusion-authorisation fusion-authentication fu$
count=0
delimiter='  '
for repo in ${repos[@]}; do
        pullJson=$(curl -s $apiRoot/repos/$owner/$repo/pulls?access_token=$apiToken&state=open&base=master)
        pullCount=$(echo ${pullJson} | jq '. | length')
        printf "%s %s $repo \n" $pullCount "${delimiter:${#pullCount}}"
        count=`expr $count + $pullCount`
done
echo TOTAL PRs: $count
