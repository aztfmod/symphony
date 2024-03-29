#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

# variables
declare MODE="shared"
declare REPO_NAME=""
declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh
source ../lib/utils.sh

# register &  arguments
shArgs.arg "MODE" -m --mode PARAMETER true
shArgs.arg "REPO_NAME" -r --repository PARAMETER true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

usage() {
    _helpText=" Usage: $me

  -m  | --mode <shared or project>      OPTIONAL: should be either shared or project, if project repository should be specified
  -r  | --repository  <repo name>       OPTIONAL: name of repo to fetch token from
  -d  | --debug                         OPTIONAL: Flag to turn debug logging on.
"
                
    _information "$_helpText" 1>&2
    exit 1
}  

check_inputs(){ 
    _debug_line_break
    _debug "             Mode : $MODE"
    _debug "  Repository Name : $REPO_NAME"
    _debug "       Debug Flag : $DEBUG_FLAG"
    _debug_line_break

}


get_shared_runner_token(){
    registration_token=`sudo gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token"`

    echo $registration_token
}

get_project_runner_token(){
    local repoName=$1

    project_token=`sudo gitlab-rails runner -e production "puts Project.find_by(name: '${repoName}').runners_token"`
    
    echo $project_token
}

main(){
    print_banner

    check_inputs

    if [ $MODE == "project" ]; then
        _debug "Fetching project runner token..."
        token=$(get_project_runner_token $REPO_NAME)
    else
        _debug "Fetching shared runner token"
        token=$(get_shared_runner_token)
    fi

    echo $token
}

main