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
  -g  | --group <Resource_Group_name>    REQUIRED Resource group to place the MSI in.
  -l  | --location <azure location>      REQUIRED: Azure region.
  -i  | --ips  <IP Address list>         REQUIRED: List of IP addresses to allow thrue firewall.  (delimiter is space \"a b c\")
  -o  | --offer <image offer>            OPTIONAL: Name of gitlab offer.  (Default is gitlab).
  -p  | --publisher <image publisher>    OPTIONAL: Name of publisher.  (Default is Bitnami).
  -k  | --key <SSH public key file>      OPTIONAL: path to SSH public key.  (Default is ~/.ssh/id_rsa.pub).
  -n  | --name  <server name>            OPTIONAL: Name you want the gitlab server to use.  (Default is gitlab-server)
  -c  | --use-self-signed-cert <label>   OPTIONAL: Configure DNS label.  Must run script post deployment to configure gitlab to use self-signed cert.
  -s  | --sku  <environment name>        OPTIONAL: VM Sku.  (Default is Standard_D4s_v3)
  -d  | --debug                          OPTIONAL: Flag to turn debug logging on.
   
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