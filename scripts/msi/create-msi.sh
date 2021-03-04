#!/usr/bin/env bash
set -euo pipefail

declare me=`basename "$0"`

# variables
declare RESOURCE_GROUP=""
declare MSI_NAME=""
declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

# register &  arguments
shArgs.arg "RESOURCE_GROUP" -g --group PARAMETER true
shArgs.arg "MSI_NAME" -n --name PARAMETER true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.parse $@

main(){
  verify_tool_exists "az"
  check_inputs

# Create MSI
az identity create -n $MSI_NAME -g $RESOURCE_GROUP

# Configure MSI Permissions  
}

check_inputs(){ 
  if [ -z "$RESOURCE_GROUP" ]; then
    _error "Resource Group is required!"
    usage
  fi
  if [ -z "$MSI_NAME" ]; then
    _error "Managed Identity Name is required!"
    usage
  fi    
}

verify_tool_exists() {
  local tool=$1
  if [ ! -x "$(command -v $tool)" ]; then
    _error "$tool is not installed and is a required dependency for this script!"
    usage
  fi  
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
  -g | --group <Resource_Group_name>    Resource group to place the MSI in.
  -n | --name  <managed identity name>  Name of the MSI to create.
  -d | --debug                          Turn debug logging on.
   
   dependencies:
   -az $azStatusMessage"
                
    _information "$_helpText" 1>&2
    exit 1
}  

print_banner(){
  cat << "EOF"
                           _                       
                          | |                      
 ___ _   _ _ __ ___  _ __ | |__   ___  _ __  _   _ 
/ __| | | | '_ ` _ \| '_ \| '_ \ / _ \| '_ \| | | |
\__ \ |_| | | | | | | |_) | | | | (_) | | | | |_| |
|___/\__, |_| |_| |_| .__/|_| |_|\___/|_| |_|\__, |
      __/ |         | |                       __/ |
     |___/          |_|                      |___/                                                         

EOF
}

main

