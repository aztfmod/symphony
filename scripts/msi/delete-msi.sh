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
declare MSI_CLIENT_ID=""
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
    
    _danger "**** Confirm Delete of Managed Identity ****"
    _danger "Managed Identity Name: $MSI_NAME"
    _danger "       Resource Group: $RESOURCE_GROUP"
    _line_break

    read -p "  Are you sure? (y/n) " CONT
    echo
    if [ "$CONT" == "y" ]; then
        #https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-cli
        az identity delete -n $MSI_NAME -g $RESOURCE_GROUP
                
        _success "Deleted Managed Identity: $MSI_NAME"        
    else         
        _danger "Aborted Deletion"
    fi
    
        
   
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

