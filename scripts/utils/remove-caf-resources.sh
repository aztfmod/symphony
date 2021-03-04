#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

# variables
declare ENVIRONMENT=""
declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

# register &  arguments
shArgs.arg "ENVIRONMENT" -e --env PARAMETER true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.parse $@

main(){
    check_inputs

    resourceGroups=($(az group list --query "[?tags.environment=='$ENVIRONMENT' && tags.landingzone].{Name:name}" -o tsv))
    if [ ${#resourceGroups[@]} -eq 0 ]; then
        _information "No Resource Groups found for CAF env $ENVIRONMENT!"
        _line_break
        exit 0
    fi     

    _danger "**** Confirm Delete of CAF Resources ****"
    _danger "Environment: $ENVIRONMENT"    
    _line_break

    read -p "  Are you sure? (y/n) " CONT
    echo
    if [ "$CONT" == "y" ]; then
      
        for group in $resourceGroups
        do
          _information "az group delete -n $group --yes --no-wait"
          #az group delete -n $group --yes --no-wait
        done

        _success "Deleted Resource Groups for CAF env $ENVIRONMENT"    
    else         
        _danger "Aborted Deletion"
    fi   
}

check_inputs(){ 
    if [ -z "$ENVIRONMENT" ]; then
        _error "Environment Name is required!"
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
  -e | --env  <environment name>        Name of the CAF environment to delete.
  -d | --debug                          Turn debug logging on.
   
   dependencies:
   -az $azStatusMessage"
                
    _information "$_helpText" 1>&2
    exit 1
}  

main

