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


## Run the GitLab runner server deployment

### Obtain the .crt file

First, run the scp-from-server.sh script to obtain the .crt file needed for runner setup.

```bash

./scp-from-server.sh \
    -f <server-fqdn> \
    -d 

# Parameter specifications
    -f my-gitlab-server.eastus2.cloudapp.azure.com \  # FDQN (use DNS name label and location specified above, required)
    -d                                                # Debug flag (optional)
```

Observe that the necessary .crt file exists within the .data folder:

e.g.  
```
~/work/symphony/.data/ssl/server.crt
```
where /.data is at the root of your working folder.

### Configure values for the runner setup 

The runner server creation script [gitlab-runner-setup.sh](./gitlab-runner-setup.sh), is invoked by the [install.sh](./install.sh) script. 


NOTE: As of this writing, the install.sh script contains the following:
- (commented out) a call to gitlab-server-setup.sh
- a set of values needed from the server VM
- a call to gitlab-runner-setup.sh, with the necessary parameters
 
 The expected parameters for gitlab-runner-setup.sh (shown below) need to be obtained from one or more locations/methods. 
 
 To get values for the parameters, 
 - Inspect the .json file exported into the /.data folder by the server setup process to observe the values in it, e.g. ./data/gitlab-server.json
 - Capture the token obtained from running fetch-gitlab-token.sh earlier. 
 - Capture the location of the .crt file generated earlier

e.g.
 ```json
{
    "resourceGroup": "<resource-group>",
    "vmName": "<gitlab-server>",
    "vmPublicIp": "1.1.1.1",
    "vmPrivateIp": "0.0.0.0",
    "user": "<gitlab-user>",
    "fqdn": "<server-fqdn>",
    "sshKey": "<ssh-key>"
}
 ```

To assign the following values in install.sh:
* RESOURCE_GROUP: use the "resourceGroup" value from the .json file
* GITLAB_TOKEN: use the token obtained from running fetch-gitlab-token.sh 
* GITLAB_URL: use the "fqdn" value from the .json file
* CERT_PATH: use the path for the .crt file exported by running scp-from-server.sh
* SERVER_INTERNAL_IP: use the "vmPrivateIp" value from the .json file
 
 
### Kick off the runner setup 

After assigning the necessary values in install.sh, run it as shown below:

```bash
./install.sh 
```

This should invoke gitlab-runner-setup.sh, which has the following parameters:

```bash
./gitlab-runner-setup.sh \
    -g <resource-group-name> \
    -d
    -c <cert-path> \
    -gt <gitlab-token> \
    -gd <gitlab-url> \
    -si <server-private-ip> \
    -f 

# Parameter specifications
    -g gitlab-test-rg \                         # Deployment resource group name (required)
    -d                                          # Debug flag (optional)
    -c ~/work/symphony/.data/ssl/server.crt     # cert path (required)
    -gt "abcde-fghijklmnopqrst"                 # gitlab token (required)
    -gd "server.eastus.cloudapp.azure.com"      # gitlab server URL (required)
    -si "00.00.00.00"                           # server's private IP (required)
    -f                                          # (OPTIONAL) full mode (5 VMs instead of 1)
```

NOTE: The -f flag will invoke the creation of 5 VMs (instead of 1 VM), with 5 runners each. For a quick test, it is easier to leave out the -f parameter for faster results.

To verify that the server and the runners have been created:
1. Browse the resource group in the Azure portal to verify that the desired VMs have been created. 
2. For each runner VM, navigate your browser to the Gitlab server and verify that the logon screen is visible.
3. Register one or more users and then log in as a user to verify that the user experience is working as expected. 

