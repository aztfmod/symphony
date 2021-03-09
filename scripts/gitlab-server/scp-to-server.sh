#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

declare DIRECTORY=./configure-server
declare FQDN=""
declare SSH_PUBLIC_KEY_FILE="~/.ssh/id_rsa"
declare USER="gitlab"

source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

shArgs.arg "FQDN" -f --fqdn PARAMETER true
shArgs.arg "DIRECTORY" -d --directory PARAMETER true
shArgs.arg "SSH_PUBLIC_KEY_FILE" -k --key PARAMETER true
shArgs.arg "USER" -u --user PARAMETER true

shArgs.parse $@

check_inputs(){ 
    _debug_line_break
    _debug "        Directory : $DIRECTORY"
    _debug "             FQDN : $FQDN"
    _debug "   SSH Public Key : $SSH_PUBLIC_KEY_FILE"
    _debug "             User : $USER"
    _debug_line_break

    if [ -z "$DIRECTORY" ]; then
        _error "Directory is required!"
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
  -d  | --directory  <Local Directory>        REQUIRED: directory to copy to server
  -k  | --key <SSH public key file>           OPTIONAL: path to SSH public key.  (Default is ~/.ssh/id_rsa.pub).
  -u  | --user <username>                     OPTIONAL: admin username (Default is gitlab)
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

    target="${USER}@${FQDN}:/home/${USER}/${DIRECTORY}"

    echo "scp'ing files in directory ${DIRECTORY} to ${target}"
    
    scp -i $SSH_PUBLIC_KEY_FILE -r ${DIRECTORY} ${target}
}

main