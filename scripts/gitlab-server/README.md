# Configure a GitLab environment that supports CAF/Lucidity Development

This document describes the steps needed to create a GitLab server in your Azure account.

## On Local WSL1/2 or Linux Instance

### Pre-requisites

- This GitLab instance is created from a Bitnami image and requires the installer to accept the terms of the license. Login to az and run the following to accept the terms if not previously accepted.

```bash
az login

urn=$(az vm image list --all -f gitlab -p bitnami --query [].urn -o tsv)

az vm image terms accept \
    --urn ${urn}
```

- Create a DNS entry (doc it)

### Run the gitlab server deployment

- Server creation script [gitlab-server-setup.sh](./gitlab-server-setup.sh)

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
    -c my-gitlab-server1 \                      # GitLab instance DNS name label (required)
    -d                                          # Debug flag (optional)

```

The server is now created and you can confirm by reviewing your Azure account for the available resources:

```bash
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
# scripts/gitlab-server folder

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

## On GitLab Server via SSH

Detailed step walk-through provided below using the following script files.

- Server setup [scripts in configure-server](./configure-server)
  - [configure-gitlab.sh](./configure-server/configure-gitlab.sh)
  - [fetch-gitlab-token.sh](./configure-server/fetch-gitlab-token.sh)
  - [create-account(s).sh](./configure-server/create-account.sh)
  - [create-environment(s).sh](./configure-server/create-environment.sh)

SSH into the GitLab server.

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

# Repeat this command for each new user.
```
