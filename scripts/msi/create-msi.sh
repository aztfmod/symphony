#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

# variables
declare RESOURCE_GROUP=""
declare MSI_NAME=""
declare ENVIRONMENT=""
declare DEBUG_FLAG=false
declare LAUNCHPAD_RGS=
declare MSI_PRINCIPAL_ID=""
declare MSI_OBJECT_ID=""
declare SUBSCRIPTION_ID=""

# includes
source ./utils.sh
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

# register &  arguments
shArgs.arg "RESOURCE_GROUP" -g --group PARAMETER true
shArgs.arg "MSI_NAME" -n --name PARAMETER true
shArgs.arg "ENVIRONMENT" -e --env PARAMETER true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.parse $@

main(){
    verify_tool_exists "az"
    SUBSCRIPTION_ID=$(az account show --query "{id:id}" -o tsv)

    check_inputs
    
    # Create MSI - az identity create will create or update. Calling a second time will not change the MSI
    # https://docs.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest
    MSI_PRINCIPAL_ID=$(az identity create -n $MSI_NAME -g $RESOURCE_GROUP | jq -r ".principalId")
    MSI_OBJECT_ID=$(az ad sp show --id $MSI_PRINCIPAL_ID --query objectId --out tsv)

    _information "Created Managed Identity $MSI_NAME"
    _debug "MSI Name: $MSI_NAME"
    _debug "MSI Principal Id: $MSI_PRINCIPAL_ID"
    _debug "MSI Object Id: $MSI_OBJECT_ID"

    _debug_line_break

    # Configure MSI Permissions  
    load_launchpad_resource_groups
    if [ -z "$LAUNCHPAD_RGS" ]; then
      _error "Couldn't find launchpad resource groups. Please ensure there are RGs with the tags environment=demo and landingzone=launchpad"
      exit 1
    else
      _information "Launchpad Resource Groups Loaded"
    fi

    for resourceGroup in $LAUNCHPAD_RGS
    do
        _line_break
        _debug "Processing RG: $resourceGroup"

        #https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_list
        local keyVault=$(az keyvault list -g $resourceGroup --query "[].{Name:name}" -o tsv)        
        _debug "Found Keyvault: $keyVault"

        local blobStorage=$(az storage account list -g $resourceGroup --query "[].{Name:name}" -o tsv)
        _debug "Found Blob Storage Account: $blobStorage"

        _information "Setting Secret Get Permission for $MSI_PRINCIPAL_ID on Keyvault: $keyVault"
        #https://docs.microsoft.com/en-us/azure/key-vault/general/assign-access-policy-cli
        az keyvault set-policy --name "$keyVault" --object-id "$MSI_OBJECT_ID" --secret-permissions "get"

        _information "Assigning Blob Data Contributor role to $MSI_PRINCIPAL_ID on Storage Account $blobStorage"
        #https://docs.microsoft.com/en-us/cli/azure/role/assignment?view=azure-cli-latest
        #https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad-rbac-cli#resource-group-scope 
        az role assignment create --role "Storage Blob Data Contributor" --assignee-object-id  "$MSI_OBJECT_ID" --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$resourceGroup/providers/Microsoft.Storage/storageAccounts/$blobStorage" -o none 1>&2
    done
    
    _line_break
    _information "Permissions successfully configured for Managed Identity $MSI_NAME"
}

load_launchpad_resource_groups() {
    _debug "Loading Resource Groups for Launchpad:"

    # https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az_group_list
    LAUNCHPAD_RGS=$(az group list --query "[?tags.environment=='$ENVIRONMENT' && tags.landingzone=='launchpad'].{Name:name}" -o tsv)
}

check_inputs(){ 
    _debug_line_break
    _debug "      Subscription Id : $SUBSCRIPTION_ID"
    _debug "       Resource Group : $RESOURCE_GROUP"
    _debug "Managed Identity Name : $MSI_NAME"
    _debug "     Environment Name : $ENVIRONMENT"
    _debug "                Debug : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$RESOURCE_GROUP" ]; then
        _error "Resource Group is required!"
        usage
    fi
    if [ -z "$MSI_NAME" ]; then
        _error "Managed Identity Name is required!"
        usage
    fi    
    if [ -z "$ENVIRONMENT" ]; then
        _error "Environment Name is required!"
        usage
    fi      
}

main

