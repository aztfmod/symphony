#!/usr/bin/env bash
#set -euo pipefail

# variables
declare __SUBSCRIPTION_ID__=""
declare PUBLIC_KEY="~/.ssh/id_rsa.pub"
declare VM_PREFIX="gitlab-runner"
declare VM_COUNT=1
declare VM_SIZE="Standard_D8s_v3"
declare VM_IMAGE="UbuntuLTS"
declare CERT_PATH=""
declare SERVER_INTERNAL_IP=""

# script parameters
declare DEBUG_FLAG=false
declare RESOURCE_GROUP=""
declare MODE_FULL=false # true=1 vm 5 runners, 1 msi  false=5 vms 5 runner each 1 msi per vm
declare GITLAB_TOKEN=""
declare GITLAB_DOMAIN=""
declare GITLAB_URL=""

# includes
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh
source ../lib/utils.sh

# register &  arguments
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true
shArgs.arg "VM_PREFIX" -p --prefix PARAMETER true
shArgs.arg "RESOURCE_GROUP" -g --group PARAMETER true
shArgs.arg "MODE_FULL" -f --full FLAG true
shArgs.arg "CERT_PATH" -c --cert-path PARAMETER true
shArgs.arg "GITLAB_TOKEN" -gt --gitlab-token PARAMETER true
shArgs.arg "GITLAB_DOMAIN" -gd --gitlab-domain PARAMETER true
shArgs.arg "SERVER_INTERNAL_IP" -si --server-ip PARAMETER true

shArgs.parse $@

main(){
    print_banner
    verify_tool_exists "az"
    check_inputs
    check_az_is_logged_in

    if [ "$MODE_FULL" == true ]; then
        _debug "Running in full mode."
        for i in {1..5}; do
            local vmName="$VM_PREFIX-$i"
            create_single_vm "$vmName"
        done
    else
        _debug "Running in basic mode. "
        local vmName="$VM_PREFIX-1"
        create_single_vm "$vmName"
    fi;

    _success "GitLab Runner VM Created!"
}

create_single_vm() {
      local vmName=$1
      _debug "Creating VM $vmName"

      local vmCreateResult=$(create_vm "$vmName")
      _debug "VM Create Result: $vmCreateResult"
      
      local publicIp=$(echo $vmCreateResult | jq -r '.publicIpAddress')
      _debug "VM Created! Public Ip: $publicIp"

      add_ip_to_known_hosts "$publicIp"

      wait_for_cloud_init_completion "$publicIp"
      copy_cert_to_vm "$publicIp"

      _debug "Creating MSI $vmName"
      local msiId=$(create_msi "$vmName")
      _debug "msiId $msiId"
      assign_msi "$vmName"

      add_server_private_ip_to_hosts_file "$publicIp"
      copy_custom_runner_image_to_vm "$publicIp" "$msiId" "$vmName"
}

add_server_private_ip_to_hosts_file() {
    local ip=$1
    _debug "echo '$SERVER_INTERNAL_IP $GITLAB_DOMAIN' | sudo tee -a /etc/hosts"

    ssh gitlab@$ip  "echo '$SERVER_INTERNAL_IP $GITLAB_DOMAIN' | sudo tee -a /etc/hosts"
}

assign_msi() {
    local vmName=$1
    az vm identity assign -g $RESOURCE_GROUP -n $vmName --identities $vmName
}

create_msi() {
    local msiName=$1
    local msiId=$(az identity create -n $msiName -g $RESOURCE_GROUP | jq -r ".id")
    echo $msiId
}

copy_custom_runner_image_to_vm() {
    local ip=$1
    local msiId=$2
    local agentName=$3
    scp -r ./runner/custom-agent "gitlab@$ip":~/
    scp $CERT_PATH "gitlab@$ip":~/custom-agent/gitlab.crt 
    ssh gitlab@$ip "chmod +x ~/custom-agent/configure-runners.sh && cd ~/custom-agent && ./configure-runners.sh $msiId $GITLAB_TOKEN $GITLAB_URL $agentName $GITLAB_DOMAIN $SERVER_INTERNAL_IP"
}

copy_cert_to_vm() {
    local ip=$1
    scp $CERT_PATH "gitlab@$ip":~/gitlab.crt
    ssh gitlab@$ip 'sudo mv ~/gitlab.crt /usr/local/share/ca-certificates/gitlab.crt'
    ssh gitlab@$ip 'sudo update-ca-certificates '
}

create_vm() {
    local vmName=$1
    result=$(az vm create -n $vmName -g $RESOURCE_GROUP --size $VM_SIZE --image $VM_IMAGE --storage-sku Premium_LRS --admin-username gitlab --ssh-key-values $PUBLIC_KEY --custom-data "runner/cloud-config.yml" 2>&1)
    check_command_status "$result" $?
    echo $result
}

wait_for_cloud_init_completion() {
    sleep 5
    local ip=$1
    _information "Waiting for cloud init to complete."
    _debug "running: ssh gitlab@$ip 'cloud-init status'"

    status=$(ssh gitlab@$ip 'cloud-init status')
    _debug "got status:$status."
    while [ "$status" != "status: done" ]; do
        _debug "sleeping for 10 seconds"
        sleep 10
        _debug "running: ssh gitlab@$ip 'cloud-init status'"
        status=$(ssh gitlab@$ip 'cloud-init status')  
        _debug "got status:$status."
    done
}

check_command_status() {
  local result=$1
  local status=$2
  if [ "$status" != "0" ]; then
      _error "$result"
      exit $status
  fi  
}

check_public_key(){
  if [ ! -d "$PUBLIC_KEY" ]; then
    _error "Public key not found at $PUBLIC_KEY"
    exit 0
  fi
}

_az(){
  local command=$@
  az $command
}

check_inputs(){ 
    GITLAB_URL="https://$GITLAB_DOMAIN/"  
    _debug_line_break
    _debug "      Subscription Id : $__SUBSCRIPTION_ID__"
    _debug "         Gitlab Token : $GITLAB_TOKEN"
    _debug "           Gitlab Url : $GITLAB_URL"
    _debug "       Resource Group : $RESOURCE_GROUP"
    _debug "            Cert Path : $CERT_PATH"
    _debug "                Debug : $DEBUG_FLAG"
    _debug "            VM Prefix : $VM_PREFIX"
    _debug "            Full Mode : $MODE_FULL"
    _debug "         GitLab Token : $GITLAB_TOKEN"
    _debug "        GitLab Domain : $GITLAB_DOMAIN"    
    _debug "           Gitlab Url : $GITLAB_URL"    
    _debug "    Server Private IP : $SERVER_INTERNAL_IP"        
    _debug "                Debug : $DEBUG_FLAG"
    _debug_line_break



    if [ -z "$RESOURCE_GROUP" ]; then
        _error "Resource Group is required!"
        usage
    fi


}

usage() {
    local azStatusMessage
    if [ -x "$(command -v az)" ]; then
        azStatusMessage=$(_success "installed - you're good to go!")
    else
        azStatusMessage=$(_error "not installed")
    fi    

    _helpText=" Usage: $me
  -d | --debug                          Turn debug logging on.
   
   dependencies:
   -az $azStatusMessage"               
    _information "$_helpText" 1>&2
    exit 1
}  

main
