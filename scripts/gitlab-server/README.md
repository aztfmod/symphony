# Configure a GitLab environment that supports CAF/Lucidity Development

This document describes the steps needed to create a GitLab server in your Azure account. 

## Pre-requisites

- This GitLab instance is created from a Bitnami image and requires the installer to accept the terms of the license. Login to az and run the following to accept the terms if not previously accepted.
```bash
az login

urn=$(az vm image list --all -f gitlab -p bitnami --query [].urn -o tsv)

az vm image terms accept \
    --urn ${urn}
```

- Create a DNS entry (doc it)

## Steps to complete buildout
  - Run the gitlab server deployment [gitlab-server-setup.sh](./gitlab-server-setup.sh)
```bash
cd scripts/gitlab-server

./gitlab-server-setup.sh \
    -g gitlab-test-rg \
    -l eastus2 \
    -i "##.##.##.#0 ##.##.##.#1 ##.##.##.#2" \
    -c my-gitlab-server1 \
    -d

# Parameter specifications
    -g gitlab-test-rg \                         # Deployment resource group name (required)
    -l eastus2 \                                # Deployment location (required) (required)
    -i "##.##.##.#0 ##.##.##.#1 ##.##.##.#2" \  # Router public IP list for inbound access to instance (required)
    -c my-gitlab-server1 \                      # GitLab instance DNS name label
    -d                                          # Debug flag (optional)
```
The server is now created and you can confirm by reviewing your Azure account for the available resources:    
```
Azure
    / gitlab-test-rg
        / gitlab-server
        / gitlab-server_OsDisk_1_a1b2c3...
        / gitlab-serverNSG
        / gitlab-serverPublicIP
        / gitlab-serverVMNic
        / gitlab-serverVNET
```

Copy files from the configure-server folder over to the GitLab-Server vm via scp.
```bash
./scp-to-server.sh \
    -f my-gitlab-server1.eastus2.cloudapp.azure.com \
    -s ./configure-server \
    -d \
    -r

# Parameter specifications
    -f my-gitlab-server1.eastus2.cloudapp.azure.com \ # FDQN (use DNS name label and location specified above, required)
    -s ./configure-server \                           # Directory to copy (required)
    -r \                                              # Remove first flag (optional) 
    -d                                                # Debug flag (optional)
```

Once the files are copied, SSH into the GitLab server and run the following setup scripts.
```bash
ssh gitlab@my-gitlab-server1.eastus2.cloudapp.azure.com

    Linux gitlab-server 4.19.0-14-cloud-amd64 #1 SMP Debian 4.19.171-2 (2021-01-30) x86_64

    The programs included with the Debian GNU/Linux system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
    permitted by applicable law.
        ___ _ _                   _
        | _ |_) |_ _ _  __ _ _ __ (_)
        | _ \ |  _| ' \/ _` | '  \| |
        |___/_|\__|_|_|\__,_|_|_|_|_|
    
    *** Welcome to the Bitnami GitLab CE 13.9.3-0                   ***
    *** Documentation:  https://docs.bitnami.com/azure/apps/gitlab/ ***
    ***                 https://docs.bitnami.com/azure/             ***
    *** Bitnami Forums: https://community.bitnami.com/              ***
    Last login: Wed Mar 00 00:00:00 2021 from ###.##.##.###

bitnami@gitlab-server:~$ 
```

Script 1 - configure GitLab
```bash
cd configure-server/

./configure-gitlab.sh \
    -f my-gitlab-server1.eastus2.cloudapp.azure.com \
    -i ##.##.##.### \
    -p xxxxxxxxxxxx \
    -d

# Parameter specifications
    -f my-gitlab-server1.eastus2.cloudapp.azure.com \       # FQDN of gitlab-server (required)
    -i ##.##.##.### \                                       # Public IP of gitlab-server (from Azure, required)
    -p xxxxxxxxxxxx \                                       # Complex password for root admin (required)
    -d                                                      # Debug flag (optional)
```

Script 2 - retrieve tokens for runner agents
```bash
# Shared token
./fetch-gitlab-token.sh

# ab12C-............Yz

# Project runner token with default GitLab values
./fetch-gitlab-token.sh \
    -m project \
    -r Monitoring \
    -d

# aB1...............Yz
```

Script 3 - add users to GitLab instance
```bash
# Add user
./create-account.sh \
    -u myusername \
    -n John Doe \
    -e jdoe@microsoft.com \
    -a true \
    -d

# Parameter specifications
    -u myusername \          # Username (required)
    -n John Doe \            # Full Name (required)
    -e jdoe@microsoft.com \  # EMail address (required)
    -a true \                # Administrator flag (true | false, default false)
    -d                       # Debug flag (optional)
```

Script 4 - create a new environment
```bash
# Add user
./create-environment.sh     # Pending completion
```


### Generate a certificate for the dns entry with letsencrypt (doc it)

- determine the version of gitlab
- generate managed identities and assign contributor to sub (TODO - needs validation)

## Configure the server (richard)

- deploy maretplace image (size, region, dns)
- install the certificate (cert path)
- update config with dns entry
- change firewall to use ssh for specific IP addresses, enable access for runners within vnet
- ssh to server
  - setup accounts
  - get gitlab token
  - setup environments

## Configure the runners (hattan)

- provision 1 or 5 vms (1 vm - all landing zones w/ 5 runners or 5 vms 1..n runners per landing zone)
- install the certificate
- generate the msi's 1 per landing zone or 1 for all landing zones
- provision runners min 1 per landing zone (msi)
- register runners
- assign managed identity to runner VM after boot

## provision launchpad and caf foundations

- TODO

## Configurable parameters

-use self signed cert
- region
- subscription
- gitlab server sku
- gitlab server dns
- IPs for users accessing server and runners
- accounts
- environments
- gitlab runner sku
- 1 or 5 runners

## Acceptance Criteria

- starting with self-signed cert
- gitlab server provisioned
- runner vms provisioned and connected to server
- runners provisioned on vms (priority is 1 vm to start for MVP)
- msi configured
  - setup accounts
  - get gitlab token
  - setup environments

## Configure the runners

- provision 1 or 5 vms (1 vm - all landing zones w/ 5 runners or 5 vms 1..n runners per landing zone)
- install the certificate
- generate the msi's 1 per landing zone or 1 for all landing zones
- provision runners min 1 per landing zone (msi)
- register runners
- assign managed identity to runner VM after boot

## provision launchpad and caf foundations

- TODO

## Configurable parameters

- region
- subscription
- gitlab server sku
- gitlab server dns
- IPs for users accessing server and runners
- accounts
- environments
- gitlab runner sku
- 1 or 5 runners

## Acceptance Criteria

- gitlab server provisioned
- runner vms provisioned and connected to server
- runners provisioned on vms (priority is 1 vm to start for MVP)
- msi configured
