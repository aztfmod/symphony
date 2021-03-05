#!/usr/bin/env bash
#set -euo pipefail

# variables
declare DEBUG_FLAG=false

# includes
source ../lib/utils.sh
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

# register &  arguments
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.parse $@

main(){
    verify_tool_exists "az"

    _success "GitLab Runner VM Created!"
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

