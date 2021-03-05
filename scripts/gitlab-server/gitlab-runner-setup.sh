#!/usr/bin/env bash
#set -euo pipefail

# variables
declare PUBLIC_KEY="~/.ssh/id_rsa.pub"
declare VM_PREFIX="gitlab-runner"
declare VM_COUNT=1
declare VM_SIZE="Standard_D8s_v3"
declare VM_IMAGE="UbuntuLTS"

# script parameters
declare DEBUG_FLAG=false
declare RESOURCE_GROUP=""
declare MODE_SECURE=false # true=1 vm 5 runners, 1 msi  false=5 vms 1 runner each 1 msi per vm

# includes
source ../lib/utils.sh
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

# register &  arguments
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.arg "VM_PREFIX" -p --prefix PARAMETER true
shArgs.arg "RESOURCE_GROUP" -g --group PARAMETER true
shArgs.arg "MODE_SECURE" -s --secure FLAG true

shArgs.parse $@

main(){
    verify_tool_exists "az"
    check_inputs
    check_az_is_logged_in

    if [ "$MODE_SECURE" == true ]; then
      echo "todo: create multiple vms"
    else
      create_single_vm | jq
    fi;

    _success "GitLab Runner VM Created!"
}

create_single_vm() {
  local vmName="$VM_PREFIX-1"
  result=$(az vm create -n $vmName -g $RESOURCE_GROUP --size $VM_SIZE --image $VM_IMAGE --storage-sku Premium_LRS --ssh-key-values "@~/.ssh/id_rsa.pub" 2>&1)
  check_command_status "$result" $?
  echo $result
}

check_command_status() {
  local result=$1
  local status=$2
  if [ "$status" != "0" ]; then
      _error "$result"
      exit $status
    fi  
}
create_vm(){
  #https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az_vm_create
  #az vm create -n VM_NAME -g hackday2 --size Standard_DS12_v2 -l westus --image GitHub:GitHub-Enterprise:GitHub-Enterprise:3.0.1 --storage-sku Premium_LRS --ssh-key-values "@~/.ssh/id_rsa.pub"
  #az vm create -n VM_NAME -g hackday2 --size Standard_DS12_v2 -l westus --image GitHub:GitHub-Enterprise:GitHub-Enterprise:3.0.1 --storage-sku Premium_LRS --ssh-key-values "@~/.ssh/id_rsa.pub"
  
  echo "create vm"
}

check_public_key(){
  if [ ! -d "$PUBLIC_KEY" ]; then
    _error "Public key not found at $PUBLIC_KEY"
    exit 0
  fi
}

check_inputs(){ 
    _debug_line_break
    _debug "      Subscription Id : $__SUBSCRIPTION_ID__"
    _debug "       Resource Group : $RESOURCE_GROUP"
    _debug "       Runner VM Name : $VM_NAME"
    _debug "     Environment Name : $ENVIRONMENT"
    _debug "                Debug : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$RESOURCE_GROUP" ]; then
        _error "Resource Group is required!"
        usage
    fi
  
}

_az(){
  local command=$@
  az $command
}

usage() {
    print_banner  
    local azStatusMessage
    if [ -x "$(command -v az)" ]; then
        azStatusMessage=$(_success "installed - you're good to go!")
    else
        azStatusMessage=$(_error "not installed")
    fi    

    _helpText=" Usage: $me
  -d | --debug                          Turn debug logging on.
   
   dependencies:
   -az $azStatusMessage"               
    _information "$_helpText" 1>&2
    exit 1
}  

main

