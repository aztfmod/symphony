declare me=`basename "$0"`

verify_tool_exists() {
  local tool=$1
  if [ ! -x "$(command -v $tool)" ]; then
    _error "$tool is not installed and is a required dependency for this script!"
    usage
  fi  
}

check_az_is_logged_in(){
  __SUBSCRIPTION_ID__=$(az account show --query "{Id:id}" -o tsv  2>&1)  
  if [ "$__SUBSCRIPTION_ID__" == "Please run 'az login' to setup account." ]; then
    _error "Not logged in to az cli. Please run 'az login"
    exit 1
  else
    __SUBSCRIPTION_ID__=$(az account show --query "{Id:id}" -o tsv) 
  fi
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