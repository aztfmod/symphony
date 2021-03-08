declare PORTS_TO_OPEN=(22 80 443)

delete_nsg_rule(){
    # Example: az network nsg rule delete -n default-allow-ssh --nsg-name gitlab-serverNSG -g gitlab-test-rg
    local ruleName=$1
    local nsgName=$2
    local rgName=$3

    az network nsg rule delete -n $ruleName --nsg-name $nsgName -g $rgName
}

add_nsg_inbound_rule_for_ip(){
    # Example: az network nsg rule create 
    #   -n rguthrie-ssh --nsg-name gitlab-serverNSG -g gitlab-test-rg 
    #   --priority 500 
    #   --access Allow 
    #   --direction Inbound 
    #   --protocol Tcp 
    #   --source-address-prefixes 50.35.50.113
    #   --source-port-ranges '*'
    #   --destination-port-ranges 22 
    #   --destination-address-prefixes '*'

    local ruleName=$1
    local nsgName=$2
    local rgName=$3
    local priority=$4
    local sourceIp=$5
    local destinationPort=$6


    az network nsg rule create -n $ruleName --nsg-name $nsgName -g $rgName \
        --priority $priority --access Allow --direction Inbound --protocol Tcp \
        --source-address-prefixes $sourceIp --source-port-ranges '*' \
        --destination-address-prefixes '*' --destination-port-ranges $destinationPort
}

get_nsg_name(){
    local rgName=$1

    nsgName=$(az network nsg list -g $rgName --query [].name -o tsv)

    echo $nsgName
}

open_default_ports_for_ip()
{
    local ipAddress=$1
    local nsgName=$2
    local rgName=$3
    local priority=$4
    local ruleBaseName='AllowForIP-'    

    for port in "${PORTS_TO_OPEN[@]}"
    do
        echo "Opening port ${port} for IP Address: ${ipAddress}"
        ruleName=${ruleBaseName}$(echo $ipAddress | sed 's/\.//g')'-'${port}
        add_nsg_inbound_rule_for_ip ${ruleName} $nsgName $rgName $priority $ipAddress $port
        priority=$(($priority+1))
    done

}