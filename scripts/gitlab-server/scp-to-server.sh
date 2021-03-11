#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

# variables
declare SOURCE_DIRECTORY=./configure-server
declare TARGET_DIRECTORY=""
declare FQDN=""
declare SSH_PUBLIC_KEY_FILE="~/.ssh/id_rsa"
declare USER="gitlab"
declare REMOVE_FIRST=false
declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh
source ../lib/utils.sh

# register &  arguments
shArgs.arg "FQDN" -f --fqdn PARAMETER true
shArgs.arg "SOURCE_DIRECTORY" -d --directory PARAMETER true
shArgs.arg "SSH_PUBLIC_KEY_FILE" -k --key PARAMETER true
shArgs.arg "USER" -u --user PARAMETER true
shArgs.arg "REMOVE_FIRST" -r --removeFirst FLAG true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

main(){
    print_banner  
    check_inputs

    TARGET_DIRECTORY=$(echo ${SOURCE_DIRECTORY} | sed '0,/.\//s///')
    target="${USER}@${FQDN}:/home/${USER}/"
    remHost="${USER}@${FQDN}"
    remDir="/home/${USER}/${TARGET_DIRECTORY}"

    if [ $REMOVE_FIRST == "true" ]; then
        _information "Removing directory ${remDir} on host."
        ssh -i $SSH_PUBLIC_KEY_FILE $remHost "rm -rf ${remDir}"
    fi

    _debug "scp'ing files in directory ${SOURCE_DIRECTORY} to ${target}"
    scp -i $SSH_PUBLIC_KEY_FILE -r ${SOURCE_DIRECTORY} ${target}

    remDir="/home/${USER}/lib"

    # copy over lib folder
    scp -i $SSH_PUBLIC_KEY_FILE -r ../lib $target
}

check_inputs(){ 
    _debug_line_break
    _debug " Source Directory : $SOURCE_DIRECTORY"
    _debug "             FQDN : $FQDN"
    _debug "   SSH Public Key : $SSH_PUBLIC_KEY_FILE"
    _debug "             User : $USER"
    _debug "      removeFirst : $REMOVE_FIRST"
    _debug "       Debug Flag : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$SOURCE_DIRECTORY" ]; then
        _error "Source  is required!"
        usage
    fi
    if [ -z "$FQDN" ]; then
        _error "FQDN is required!"
        usage
    fi 
}

usage() {
    _helpText=" Usage: $me

  -f  | --fqdn <Fully Qualified Domain Name>  REQUIRED: Fully qualified domain name of gitlab server
  -s  | --sourceDir  <Local Directory>        REQUIRED: source to copy to server (must be a directory at same level or below script exec dir)
  -k  | --key <SSH public key file>           OPTIONAL: path to SSH public key.  (Default is ~/.ssh/id_rsa.pub).
  -u  | --user <username>                     OPTIONAL: admin username (Default is gitlab)
  -r  | --removeFirst                         OPTIONAL: Drop and recreate directory on host
  -d  | --debug                               OPTIONAL: Flag to turn debug logging on.
"
                
    _information "$_helpText" 1>&2
    exit 1
}

main
