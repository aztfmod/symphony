# Configure a GitLab environment that supports CAF/Lucidity Development

This document describes the steps needed to create a GitLab server in your Azure account.

#### NOTE: Devcontainer implementation (pending!)

## On Local WSL1/2 or Linux Instance

### Pre-requisites

- This GitLab instance is created from a Bitnami image and requires the installer to accept the terms of the license. Login to az and run the following to accept the terms if not previously accepted. This step only needs to be run once.

```bash
az login

urn=$(az vm image list --all -f gitlab -p bitnami --query [].urn -o tsv)

az vm image terms accept \
    --urn ${urn}
```

- Create a DNS entry (pending!)

### Run the GitLab server deployment

- Server creation script [gitlab-server-setup.sh](./gitlab-server-setup.sh)

```bash
cd scripts/gitlab-server

./gitlab-server-setup.sh \
    -g <resource-group-name> \
    -l <azure-location> \
    -i "<user-00-ip> <user-01-ip> <user-02-ip>" \
    -c <gitlab-server-name> \
    -d

# Parameter specifications
    -g gitlab-test-rg \                         # Deployment resource group name (required)
    -l eastus2 \                                # Deployment location (required) (required)
    -i "00.00.00.00 11.11.11.11 22.22.22.22" \  # User's router public IP list for Firewall inbound access to server (required)
    -c my-gitlab-server \                       # GitLab instance DNS name label (required)
    -d                                          # Debug flag (optional)

Upon successful completion you will see the following:

   Summary: gitlab-server-setup.sh
         RESOURCE GROUP: gitlab-test-rg
                VM NAME: my-gitlab-server
           VM PUBLIC IP: <server-public-ip>
          VM PRIVATE IP: <server-private-ip>
                   USER: gitlab
                   FQDN: <server-fqdn>          # my-gitlab-server.eastus2.cloudapp.azure.com
    SSH PUBLIC KEY FILE: ~/.ssh/id_rsa.pub

```

The server is now created, please note the values as they will be used in subsequent steps.    

You can confirm by reviewing your Azure subscription for the available resources:

```bash

Azure
    / gitlab-test-rg
        / my-gitlab-server
        / my-gitlab-server_OsDisk_1_a1b2c3...
        / my-gitlab-serverNSG
        / my-gitlab-serverPublicIP
        / my-gitlab-serverVMNic
        / my-gitlab-serverVNET
```

Copy files to the GitLab-Server vm using the scp-to-server.sh script found in the same working directory.   
Folders copied:
 - /configure-server
 - /lib   

```bash

./scp-to-server.sh \
    -f <server-fqdn> \
    -s <local-directory-to-copy> \
    -r \
    -d  

# Parameter specifications
    -f my-gitlab-server.eastus2.cloudapp.azure.com \  # FDQN (use DNS name label and location specified above, required)
    -s ./configure-server \                           # Directory to copy (required)
    -r \                                              # Remove first flag (optional) 
    -d                                                # Debug flag (optional)
```

## On GitLab Server via SSH

Detailed step walk-through provided below using the following script files.

- Server setup [scripts in configure-server](./configure-server)
  - [configure-gitlab.sh](./configure-server/configure-gitlab.sh)
  - [fetch-gitlab-token.sh](./configure-server/fetch-gitlab-token.sh)
  - [create-account(s).sh](./configure-server/create-account.sh)
  - [create-environment(s).sh](./configure-server/create-environment.sh)

SSH into the GitLab server.

```bash
ssh <user>@<server-fqdn>

# Parameter sample
ssh gitlab@my-gitlab-server.eastus2.cloudapp.azure.com

* Your first login will produce this security prompt, please enter 'yes' to continue: 
  
  The authenticity of host '<server-fqdn> (<server-public-ip>)' can't be established.   
  ECDSA key fingerprint is SHA256:<sha-key>.   
  Are you sure you want to continue connecting (yes/no)? yes
  ...
    
    Linux gitlab-server <GitLab-version> #1 SMP Debian <Debian-version>

    The programs included with the Debian GNU/Linux system are free software;
    the exact distribution terms for each program are described in the
    individual files in /usr/share/doc/*/copyright.

    Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent   
    permitted by applicable law.   
         ___ _ _                   _
        | _ |_) |_ _ _  __ _ _ __ (_)
        | _ \ |  _| ' \/ _` | '  \| |
        |___/_|\__|_|_|\__,_|_|_|_|_|
    
    *** Welcome to the Bitnami GitLab <GitLab-version>              ***
    *** Documentation:  https://docs.bitnami.com/azure/apps/gitlab/ ***
    ***                 https://docs.bitnami.com/azure/             ***
    *** Bitnami Forums: https://community.bitnami.com/              ***

bitnami@gitlab-server:~$ 
```

Script 1 - configure GitLab

```bash
cd configure-server/

./configure-gitlab.sh \
    -f <server-fqdn> \
    -i <server-public-ip> \
    -p <strong-password> \
    -d

# Parameter specifications
    -f my-gitlab-server.eastus2.cloudapp.azure.com \        # FQDN of gitlab-server (required)
    -i 000.000.000.000 \                                    # Public IP of gitlab-server (from Azure, required)
    -p P@ssword1! \                                         # Complex password for root admin (required)
    -d                                                      # Debug flag (optional)
```

Script 2 - retrieve tokens for runner agents

```bash
# Server token
./fetch-gitlab-token.sh

# ab12C-A1..........Yz

# Project token (with these default GitLab project values)
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
    -u <username> \
    -n <Full Name> \
    -e <email> \
    -a <true | false> \
    -d

# Parameter specifications
    -u myusername \          # Username (required)
    -n John Doe \            # Full Name (required)
    -e jdoe@microsoft.com \  # EMail address (required)
    -a true \                # Administrator flag (true | false, default false)
    -d                       # Debug flag (optional)

# Repeat this command for each new user.
```
