#!/usr/bin/env bash
#set -euo pipefail

declare USERNAME=""
declare EMAIL_ADDRESS=""
declare IS_ADMIN=""
declare DEBUG_FLAG=false

source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

shArgs.arg "USERNAME" -u --username PARAMETER true
shArgs.arg "EMAIL_ADDRESS" -e --email PARAMETER true
shArgs.arg "IS_ADMIN" -a --admin FLAG true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

check_inputs(){ 
    _debug_line_break
    _debug "               USERNAME : $USERNAME"
    _debug "          EMAIL ADDRESS : $EMAIL_ADDRESS"
    _debug "               IS ADMIN : $IS_ADMIN"    
    _debug "         Debug Flag : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$PUBLIC_IP" ]; then
        _error "Public IP is required!"
        usage
    fi
    if [ -z "$FQDN" ]; then
        _error "FQDN is required!"
        usage
    fi 

    if [ -z "$ROOT_ADMIN_PASSWORD" ]; then
        _error "Root Administrator Password is required!"
        usage
    fi 
}

usage() {
    print_banner  

    _helpText=" Usage: $me

  -i  | --ip <Server Public IP>               REQUIRED: Public IP of gitlab server
  -f  | --fqdn <Fully Qualified Domain Name>  REQUIRED: Fully qualified domain name of gitlab server
  -p  | --rootPassword <Password>             REQUIRED: Password to reset the root admin to.
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