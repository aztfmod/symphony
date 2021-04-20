#!/usr/bin/env bash

# variables
declare GROUP_NAME="<source-group-name>"
declare SOURCE_PAT="<source-pat>"
declare SOURCE_FQDN="<source-fqdn>"
declare TARGET_PAT="<target-pat>"
declare TARGET_FQDN="<target-fqdn>"

declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh


function main() {
    # Download source repos
    cloneRepos "source" $SOURCE_FQDN $SOURCE_PAT

    # Get or create target Gitlab group and projects
    confirmOrCreateTargetRepos

    # Download target repos
    cloneRepos "target" $TARGET_FQDN $TARGET_PAT

    # Copy source code to target folder while maintaining git folders
    copySourceCodeToTarget "source" "target"

    # Update target FQDNs in code
    updateFQDN "target"

    # Push target code to Gitlab repo
    pushRepos "target"
}

function cloneRepos() {
    local path=$1
    local fqdn=$2
    local pat=$3
    local groupId=""

    _information "Copying all repos in $fqdn under the $GROUP_NAME group."

    groupId=$(curl -sk "https://$fqdn/api/v4/groups?private_token=$pat" | jq '.[] | select(.name=="'$GROUP_NAME'")' | jq '.id')
    _debug "Group $path ID: $groupId"

    rm -rf $path
    mkdir $path
    cd $path
    _debug "Getting repos for https://$fqdn/api/v4/groups/$groupId"
    for repo in $(curl -sk --header "PRIVATE-TOKEN: $pat" https://$fqdn/api/v4/groups/$groupId | jq ".projects[].ssh_url_to_repo" | tr -d '"'); do git clone $repo; done;
    cd ../
}

function confirmOrCreateTargetRepos() {
    local groupId=""
    local projectId=""

    _information "Confirm or create target repos in GitLab"

    groupId=$(curl -sk "https://$TARGET_FQDN/api/v4/groups?private_token=$TARGET_PAT" | jq '.[] | select(.name=="'$GROUP_NAME'")' | jq '.id')
    _debug "Target group ID: $groupId"

   if [ -z $groupId ]; then
        _information "Group not found in target, creating target group and repos."
        groupId=$(curl -sk --request POST --header "PRIVATE-TOKEN: $TARGET_PAT" --header "Content-Type: application/json" --data '{"path": "'$GROUP_NAME'", "name": "'$GROUP_NAME'", "visibility": "internal" }' "https://$TARGET_FQDN/api/v4/groups/" | jq '.["id"]')
        _debug "Group created ID: $groupId"

        cd source
        for f in *; do
            if [ -d "$f" ]; then
                projectId=$(curl -sk --request POST --header "PRIVATE-TOKEN: $TARGET_PAT" --header "Content-Type: application/json" --data '{"path": "'$f'", "namespace_id": '$groupId', "visibility": "internal" }' "https://$TARGET_FQDN/api/v4/projects/" | jq '.["id"]')
                _debug "Project created ID: $projectId - Name: $f"
            fi
        done
        cd ../
    fi
}

function copySourceCodeToTarget() {
    local sourcePath=$1
    local targetPath=$2

    _information "Copy source files to target while preserving git info."

    cp -R $sourcePath ./temp
    find ./temp -name ".git" -exec rm -rf {} +
    find ./$targetPath -mindepth 2 ! -name '.git' ! -path '*.git*' -exec rm -rf {} +
    cd temp
    cp -R . ../$targetPath
    cd ../
    rm -rf temp
}

function updateFQDN() {
    local codePath=$1

    _information "Find and update FQDN references to $TARGET_FQDN"

    cd $codePath
    find . -type f -exec sed -i 's/'$SOURCE_FQDN'/'$TARGET_FQDN'/g' {} +
    find . -type f -name "*.yml" -exec sed -i "s/base_uri: ''/base_uri: '$TARGET_FQDN'/g" {} +
    cd ../
}

function pushTargetRepos() {
    local repoPath=$1

    _information "Run Git add, commit and push on all repos in $repoPath"

    cd $repoPath
    for f in *; do
       if [ -d "$f" ]; then
            echo "Pushing $f"
            git -C $f add .
            git -C $f commit -m "updated"
            git -C $f push
        fi
    done
    cd ../
}

main
