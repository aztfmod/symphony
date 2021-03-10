#!/usr/bin/env bash
#set -euo pipefail

declare PUBLIC_IP=""
declare FQDN=""
declare ROOT_ADMIN_PASSWORD=""
declare DEBUG_FLAG=false
PATH_TO_GITLAB_RB=/etc/gitlab/gitlab.rb

source ../lib/shell_logger.sh
source ../lib/sh_arg.sh

shArgs.arg "FQDN" -f --fqdn PARAMETER true
shArgs.arg "PUBLIC_IP" -i --ip PARAMETER true
shArgs.arg "ROOT_ADMIN_PASSWORD" -p --rootPassword PARAMETER true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

check_inputs(){ 
    _debug_line_break
    _debug "               FQDN : $FQDN"
    _debug "          Public IP : $PUBLIC_IP"
    _debug "Root Admin Password : $ROOT_ADMIN_PASSWORD"    
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

replace_external_url(){
    SEARCH_STRING="external_url "
    REPLACEMENT_STRING="${SEARCH_STRING}'https:\/\/${FQDN}'"

    _debug "SEARCH_STRING is: '${SEARCH_STRING}'"

    sudo sed -i "s/^\(${SEARCH_STRING}\).*/${REPLACEMENT_STRING}/" $PATH_TO_GITLAB_RB

}

generate_self_signed_ssl_cert(){
    pushd /etc/gitlab/ssl
    
    # Delete the existing server cert if one exist.
    sudo rm -rf server.*

    # Generate the new self-signed cert
    sudo openssl genrsa -out "server.key" 2048 

    # Generate the public key
    sudo openssl req -new -key "server.key" -subj "/CN=${FQDN}" -addext "subjectAltName = DNS:${FQDN}"  -out "server.csr"

    # Generate the crt file
    sudo openssl x509 -req -days 365 -in "server.csr" -signkey "server.key"  -out "server.crt"  

    popd
}

reset_root_password(){
    sudo gitlab-rails runner -e production "user = User.find(1); user.password =\"${ROOT_ADMIN_PASSWORD}\"; user.password_confirmation = \"${ROOT_ADMIN_PASSWORD}\"; user.send_only_admin_changed_your_password_notification!;user.save!;"
}

main(){
    check_inputs

    replace_external_url

    generate_self_signed_ssl_cert

    sudo gitlab-ctl reconfigure

    reset_root_password

}

main