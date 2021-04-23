verify_tool_exists() {
  local tool=$1
  if [ ! -x "$(command -v $tool)" ]; then
    _error "$tool is not installed and is a required dependency for this script!"
    usage
  fi  
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
  -g | --group <Resource_Group_name>    Resource group to place the MSI in.
  -n | --name  <managed identity name>  Name of the MSI to create.
  -e | --env  <environment name>        Name of the CAF environment where the launchpad was deployed to.
  -d | --debug                          Turn debug logging on.
   
   dependencies:
   -az $azStatusMessage"
                
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