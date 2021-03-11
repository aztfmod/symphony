#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

declare TARGET_DIRECTORY="./files-from-server"
declare FQDN=""
declare SSH_PUBLIC_KEY_FILE="~/.ssh/id_rsa"
declare USER="gitlab"
declare REMOVE_FIRST=false
declare DEBUG_FLAG=false

source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

shArgs.arg "TARGET_DIRECTORY" -t --targetDirectory PARAMETER true
shArgs.arg "FQDN" -f --fqdn PARAMETER true
shArgs.arg "SSH_PUBLIC_KEY_FILE" -k --key PARAMETER true
shArgs.arg "USER" -u --user PARAMETER true
shArgs.arg "REMOVE_FIRST" -r --removeFirst FLAG true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

check_inputs(){ 
    _debug_line_break
    _debug " Target Directory : $TARGET_DIRECTORY"
    _debug "             FQDN : $FQDN"
    _debug "   SSH Public Key : $SSH_PUBLIC_KEY_FILE"
    _debug "             User : $USER"
    _debug "      removeFirst : $REMOVE_FIRST"
    _debug "       Debug Flag : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$TARGET_DIRECTORY" ]; then
        _error "Source  is required!"
        usage
    fi
    if [ -z "$FQDN" ]; then
        _error "FQDN is required!"
        usage
    fi 
}

usage() {
    print_banner  

    _helpText=" Usage: $me
  -f  | --fqdn <Fully Qualified Domain Name>  REQUIRED: Fully qualified domain name of gitlab server
  -t  | --targetDir  <Local Directory>        OPTIONAL: target directory to copy files from server to (relative to current working dir Ex. './files-from-server')
  -k  | --key <SSH public key file>           OPTIONAL: path to SSH public key.  (Default is ~/.ssh/id_rsa.pub).
  -u  | --user <username>                     OPTIONAL: admin username (Default is gitlab)
  -r  | --removeFirst                         OPTIONAL: Drop and recreate contents in target dir
  -d  | --debug                               OPTIONAL: Flag to turn debug logging on.
"
                
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


main(){
    check_inputs

    target="${USER}@${FQDN}"

    if [ $REMOVE_FIRST == "true" ]; then
        _information "Removing target directory ${TARGET_DIRECTORY}."
        rm -rf ${TARGET_DIRECTORY}
    fi

    mkdir -p ${TARGET_DIRECTORY}

    _debug "scp'ing cert files from server ${FQDN} in to target directory ${TARGET_DIRECTORY}"

    # copy to temp since there is no sudo with 
    ssh -i $SSH_PUBLIC_KEY_FILE ${target} "sudo rm -rf /tmp/gitlab/ssl/"
    ssh -i $SSH_PUBLIC_KEY_FILE ${target} "mkdir -p /tmp/gitlab/ && sudo cp -r /etc/gitlab/ssl /tmp/gitlab/ && sudo chown -R gitlab:gitlab /tmp/gitlab/ssl"

    certPath="${target}:/tmp/gitlab/ssl/"
    scp -i $SSH_PUBLIC_KEY_FILE -r -q -o LogLevel=QUIET  ${certPath} ${TARGET_DIRECTORY}

    # delete temp dir
    ssh -i $SSH_PUBLIC_KEY_FILE ${target} "rm -rf /tmp/gitlab/ssl"
}

main