#!/usr/bin/env bash

# variables
declare GROUP_NAME=""
declare SOURCE_PAT=""
declare SOURCE_FQDN=""
declare TARGET_PAT=""
declare TARGET_FQDN=""
declare LAUNCHPAD_ENV=""

declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh
source ../lib/utils.sh

# register & arguments
shArgs.arg "GROUP_NAME" -g --group PARAMETER true
shArgs.arg "SOURCE_PAT" -sp --source-pat PARAMETER true
shArgs.arg "SOURCE_FQDN" -sd --source-fqdn PARAMETER true
shArgs.arg "TARGET_PAT" -tp --target-pat PARAMETER true
shArgs.arg "TARGET_FQDN" -td --target-fqdn PARAMETER true
shArgs.arg "LAUNCHPAD_ENV" -e --environment PARAMETER true

shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

function main() {
    check_inputs

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
    for repo in $(curl -sk --header "PRIVATE-TOKEN: $pat" https://$fqdn/api/v4/groups/$groupId | jq ".projects[].ssh_url_to_repo" | tr -d '"'); do
      _debug "Cloning $repo"
      git clone $repo;
    done
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

    if [ ! -z "$LAUNCHPAD_ENV" ]; then
        verify_tool_exists "az"
        check_az_is_logged_in

        # Add vars to group for runner execution
        addTargetGroupVariable $groupId "GODEBUG" "x509ignoreCN=0"
        addTargetGroupVariable $groupId "ARM_USE_MSI" "true"

        for i in {0..4}; do
            local msiId=""
            local level="level$i"
            local key="MSI_ID_0$i"
            msiId=$(az identity list --query "[?tags.level == '$level' && tags.environment == '$LAUNCHPAD_ENV']".clientId -o tsv)
            if [ ! -z $msiId ]; then
                echo "Adding $msiId with key $key for $level runners"
                addTargetGroupVariable $groupId $key $msiId
            fi
        done
    fi
}

function addTargetGroupVariable() {
    local groupId=$1
    local key=$2
    local value=$3

    curl -sk --request POST --header "PRIVATE-TOKEN: $TARGET_PAT" "https://$TARGET_FQDN/api/v4/groups/$groupId/variables" --form "key=$key" --form "value=$value"
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

function pushRepos() {
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
    rm -rf source target
}

check_inputs(){
    local req+=""

    _debug_line_break
    _debug " GitLab Group : $GROUP_NAME"
    _debug "   Source PAT : $SOURCE_PAT"
    _debug "  Source FQDN : $SOURCE_FQDN"
    _debug "   Target PAT : $TARGET_PAT"
    _debug "  Target FQDN : $TARGET_FQDN"
    _debug "  Environment : $LAUNCHPAD_ENV"
    _debug "        Debug : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$GROUP_NAME" ]; then
        req+="Group, "
    fi
    if [ -z "$SOURCE_PAT" ]; then
        req+="Source PAT, "
    fi
    if [ -z "$SOURCE_FQDN" ]; then
        req+="Source FQDN, "
    fi
    if [ -z "$TARGET_PAT" ]; then
        req+="Target PAT, "
    fi
    if [ -z "$TARGET_FQDN" ]; then
        req+="Target FQDN, "
    fi

    if [ ! -z "$req" ]; then
      _error "Require GitLab Server ${req:0:${#req}-2}"
      usage
    fi
}

usage() {
    local azStatusMessage
    if [ -x "$(command -v az)" ]; then
        azStatusMessage=$(_success "installed - you're good to go!")
    else
        azStatusMessage=$(_error "not installed")
    fi

    _helpText=" Usage: $me
  -g  | --group <GitLab_Group>                   REQUIRED: GitLab from server group to copy repo(s).
  -sp | --source-pat <GitLab_Source_PAT>         REQUIRED: GitLab from server user PAT with api and read_repository scopes.
  -sd | --source-fqdn <GitLab_Source_FQDN>       REQUIRED: GitLab from server fully qualified domain name, no https or path.
  -tp | --target-pat <GitLab_Target_PAT>         REQUIRED: GitLab to server user PAT with api, read_repository and write_repository scopes.
  -td | --target-fqdn <GitLab_Target_FQDN>       REQUIRED: GitLab to server fully qualified domain name, no https or path.
  -e  | --environment <Launchpad_Environment>    OPTIONAL: Launchpad environment, if provided will add GODEBUG and MSIs to target group.

  Note: Add User SSH key to user profile on both GitLab instances to allow read/write of repos.

   dependencies:
   -az $azStatusMessage"

    _information "$_helpText" 1>&2
    exit 1
}

main
