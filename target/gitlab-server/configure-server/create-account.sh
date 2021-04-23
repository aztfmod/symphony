#!/usr/bin/env bash
#set -euo pipefail

# variables
declare USERNAME=""
declare NAME=""
declare EMAIL_ADDRESS=""
declare PASSWORD="P@ssword1!"
declare IS_ADMIN=false
declare DEBUG_FLAG=false

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh
source ../lib/utils.sh

# register &  arguments
shArgs.arg "USERNAME" -u --username PARAMETER true
shArgs.arg "NAME" -n --name PARAMETER true
shArgs.arg "EMAIL_ADDRESS" -e --email PARAMETER true
shArgs.arg "PASSWORD" -p --password PARAMETER true
shArgs.arg "IS_ADMIN" -a --admin FLAG true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

check_inputs(){ 
    _debug_line_break
    _debug "               Username : $USERNAME"
    _debug "               Username : $NAME"
    _debug "          Email Address : $EMAIL_ADDRESS"
    _debug "               Password : $PASSWORD"
    _debug "               Is Admin : $IS_ADMIN"    
    _debug "             Debug Flag : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$USERNAME" ]; then
        _error "Username is required!"
        usage
    fi
    if [ -z "$NAME" ]; then
        _error "Name is required!"
        usage
    fi 
    if [ -z "$EMAIL_ADDRESS" ]; then
        _error "Email Address is required!"
        usage
    fi 
}

usage() {
    _helpText=" Usage: $me

  -u  | --username <username>           REQUIRED: User name
  -n  | --name <Full Name of user>      REQUIRED: First and Last name of user
  -e  | --email <email address>         REQUIRED: Email Address
  -p  | --password <Password>           OPTIONAL: Password (Default is P@ssw0rd1!)
  -a  | --admin                         OPTIONAL: When flag is set to true will add user to admins group.
  -d  | --debug                         OPTIONAL: Flag to turn debug logging on.

"
                
    _information "$_helpText" 1>&2
    exit 1
}  

create_account(){
    sudo gitlab-rails runner -e production "User.create!(:username => '${USERNAME}', \
        :password => '${PASSWORD}', :password_confirmation => '${PASSWORD}', \
        :email => '${EMAIL_ADDRESS}', :name => '${NAME}', :admin => ${IS_ADMIN})"

    #Confirm the user since we do not setup email.
    sudo gitlab-rails runner -e production "user = User.find_by_username '${USERNAME}'; user.confirm;"

    echo "Account created!"
}

main(){
    print_banner

    check_inputs

    create_account
}

main