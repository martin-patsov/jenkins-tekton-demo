#!/usr/bin/env bash

# make these variables parameters
org=jenkins-oscar
rootdir=~/git-repos
app_name=cars
app_version="0.0.1"

# the google project
PROJECT=jx-development
IMAGE=$app_name

# PRO TIP: If you forgot the credentials for Chartmuseum, you can get them by `jx rsh` into the pod, then executing
# `env | grep BASIC`
CHARTMUSEUM_CREDENTIALS="username:password"
CHARTMUSEUM_URL=http://chartmuseum.jx.sharepointoscar.com/api/charts

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

#rm -rf "$rootdir/$app"
# delete the cluster environment repositories
# echo -e "${GREEN}deleting jx environment github repositories...\n"
# for repo in $(jx get env -o json | jq -r '.items[].spec.source.url | select(.!=null) | sub(".*/";"") ')
# do  
#     echo -e "${RED}$org/"$repo"${NOCOLOR}"
#     #hub delete $org/"$repo" -y
# done

# delete applications
# echo -e "${GREEN}deleting jx environment github repositories...\n"
# for repo in $(jx get env -o json | jq -r '.items[].spec.source.url | select(.!=null) | sub(".*/";"") ')
# do  
#     echo -e "${RED}$org/"$repo"${NOCOLOR}"
#     #hub delete $org/"$repo" -y
# done


# delete local repos
echo -e "\n${GREEN}deleting local repo...\n"
rm -rf "$rootdir/$app_name"

echo -e "\n${GREEN}deleting Jenkins X application...\n"
jx delete application "$app_name"

echo -e "\n${GREEN}container image...\n"

for TAG in $(gcloud container images list-tags \
    gcr.io/$PROJECT/$IMAGE \
    --format='get(tags)')
do
  gcloud container images \
    delete gcr.io/$PROJECT/$IMAGE:$TAG \
    --quiet
done

# garbage collection
echo -e "\n${GREEN}perform garbage collection (pods, previews, help)..\n"
jx gc previews && jx gc pods && jx gc helm && jx gc activities

echo -e "\n${GREEN}deleting remote github repo...\n"
hub delete "$org/$app_name" -y


# 4) delete helm chart, given a version (get version by executing jx get applications)
# We should iterate through versions by executing 
# NOTE, be sure to add BASIC AUTH USERNAME AND PASSWORD TO REQUEST FIRST

#curl  -v -H "Authorization: Basic `echo -n $CHARTMUSEUM_CREDENTIALS | base64`"  --location --request DELETE "$CHARTMUSEUM_URL/$app_name/$app_version" --verbose
curl --user $CHARTMUSEUM_CREDENTIALS --location --request DELETE "$CHARTMUSEUM_URL/$app_name/$app_version"