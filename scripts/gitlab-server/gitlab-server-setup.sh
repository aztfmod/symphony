#!/usr/bin/env bash
#set -euo pipefail

declare me=`basename "$0"`

# variables
declare RESOURCE_GROUP=""
declare SERVER_NAME="gitlab-server"
declare SKU="Standard_D4s_v3"
declare LOCATION=""
declare IMAGE_OFFER="gitlab"
declare IMAGE_PUBLISHER="Bitnami"
declare IP_ACCESS_LIST=""
declare FULL_IMAGE_NAME=""
declare SSH_PUBLIC_KEY_FILE_PATH="~/.ssh/id_rsa.pub"
declare DNS_LABEL=""
declare ALLOW_ACCESS_TO_IP_ADDRESSES=""
declare NSG_NAME=""
declare SERVER_PUBLIC_IP=""
declare SERVER_PUBLIC_IP_NAME=""
FQDN=""
declare DEBUG_FLAG=false


# includes
source ./update-firewall.sh
source ./gitlab-server-utils.sh
source ../lib/shell_logger.sh
source ../lib/sh_arg.sh


# register &  arguments
shArgs.arg "RESOURCE_GROUP" -g --group PARAMETER true
shArgs.arg "SERVER_NAME" -n --name PARAMETER true
shArgs.arg "SKU" -s --sku PARAMETER true
shArgs.arg "LOCATION" -l --location PARAMETER true
shArgs.arg "IMAGE_OFFER" -o --offer PARAMETER true
shArgs.arg "IMAGE_PUBLISHER" -p --publisher PARAMETER true
shArgs.arg "SSH_PUBLIC_KEY_FILE_PATH" -k --key PARAMETER true
shArgs.arg "ALLOW_ACCESS_TO_IP_ADDRESSES" -i --ips PARAMETER true
shArgs.arg "DNS_LABEL" -c --use-self-signed-cert PARAMETER true

shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

main(){
    verify_tool_exists "az"
    SUBSCRIPTION_ID=$(az account show --query "{id:id}" -o tsv)

    check_inputs

    FULL_IMAGE_NAME=$(lookup_image_urn)

    _debug $FULL_IMAGE_NAME

    _information "Creating resource group ${RESOURCE_GROUP}"
    create_resource_group

    _information "Deploying gitlab server ${SERVER_NAME}"
    deploy

    NSG_NAME=$(get_nsg_name ${RESOURCE_GROUP})
    _information "Retrieved NSG name: '${NSG_NAME}'"

    _information "Adding firewall rules for IP's ${ALLOW_ACCESS_TO_IP_ADDRESSES}"
    configure_nsg_rules

    _information "Deleting default ssh rule default-allow-ssh"
    delete_nsg_rule 'default-allow-ssh' $NSG_NAME $RESOURCE_GROUP

    if [ -z "$DNS_LABEL" ]; then
        _information "DNS label not set, skipping confugration of label on public IP."
    else
        _information "Configuring server DNS label '${DNS_LABEL}' on public IP '${SERVER_PUBLIC_IP}'."
        lookup_public_ip_address_name
        configure_server_dns_label
    fi

    print_summary
}

check_inputs(){ 
    _debug_line_break
    _debug "       Resource Group : $RESOURCE_GROUP"
    _debug "          Server Name : $SERVER_NAME"
    _debug "                  Sku : $SKU"
    _debug "             Location : $LOCATION"
    _debug "          Image Offer : $IMAGE_OFFER"
    _debug "      Image Publisher : $IMAGE_PUBLISHER"
    _debug "  SSH Public Key path : $SSH_PUBLIC_KEY_FILE_PATH"
    _debug "  IP Addresses(Allow) : ${ALLOW_ACCESS_TO_IP_ADDRESSES}"
    _debug "            DNS Label : ${DNS_LABEL}"
    _debug "                Debug : $DEBUG_FLAG"
    _debug_line_break

    if [ -z "$RESOURCE_GROUP" ]; then
        _error "Resource Group is required!"
        usage
    fi
    if [ -z "$LOCATION" ]; then
        _error "Location is required!"
        usage
    fi 
    if [ -z "$ALLOW_ACCESS_TO_IP_ADDRESSES" ]; then
        _error "IP Address list is required!"
        usage
    fi  
}

lookup_image_urn(){
    urn=$(az vm image list --all -f $IMAGE_OFFER -p $IMAGE_PUBLISHER --query [].urn -o tsv)

    echo $urn
}

create_resource_group(){
    az group create -n $RESOURCE_GROUP -l $LOCATION
}

deploy(){
    output=$(az vm create -n $SERVER_NAME -g $RESOURCE_GROUP --size $SKU -l $LOCATION --image $FULL_IMAGE_NAME --storage-sku Premium_LRS --ssh-key-values "@${SSH_PUBLIC_KEY_FILE_PATH}" --admin-username gitlab -o json)

    _debug_json "${output}"

    SERVER_PUBLIC_IP=$(echo $output | jq -c -r .publicIpAddress)

    _information "Extracting public IP from deployment.  ${SERVER_PUBLIC_IP}"
}

configure_nsg_rules(){
    priority=500
    for ip in $ALLOW_ACCESS_TO_IP_ADDRESSES
    do
        _information "Upserting rules for ${ip}"
        open_default_ports_for_ip $ip $NSG_NAME $RESOURCE_GROUP $priority
        priority=$(($priority+100))
    done
}

lookup_public_ip_address_name(){
    SERVER_PUBLIC_IP_NAME=`az network public-ip list -g $RESOURCE_GROUP --query "[?ipAddress=='${SERVER_PUBLIC_IP}'].name" -o tsv`

    _debug "Public Ip Name is ${SERVER_PUBLIC_IP_NAME}"


}

configure_server_dns_label(){

    az network public-ip update -g $RESOURCE_GROUP -n $SERVER_PUBLIC_IP_NAME --dns-name $DNS_LABEL --allocation-method Static

    FQDN=$(az network public-ip show -g $RESOURCE_GROUP -n ${SERVER_PUBLIC_IP_NAME} --query dnsSettings.fqdn -o tsv)
}

print_summary(){
    _summary=" Summary: $me \n
         RESOURCE GROUP: ${RESOURCE_GROUP}
                VM NAME: ${SERVER_NAME}
                  VM IP: ${SERVER_PUBLIC_IP}
                   FQDN: ${FQDN}
    SSH PUBLIC KEY FILE: ${SSH_PUBLIC_KEY_FILE_PATH}
"

                
    _information "$_summary" 1>&2
}

main