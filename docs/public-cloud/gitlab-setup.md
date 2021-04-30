# Gitlab Setup Guide for CAF Sample App

This document outlines the steps necessary to set up a sample CAF (Cloud Adoption Framework) application in GitLab. 

Before you begin:

0. Clone the [symphony](https://github.com/aztfmod/symphony) repo.
1. Ensure that Docker is up and running on your local machine.
2. Launch the Dev Container provided with the project.

To summarize the steps:

1. Set up the GitLab server with ```gitlab-server-setup.sh```
2. Deploy the launchpad landing zone manually to set up MSIs, using ```rover```
3. Set up SSH Keys and clone repostories using ```clone-repos.sh```
4. Set up the Gitlab runners with ```install.sh```
5. Run pipelines in Gitlab and troubleshoot as necessary

# 1. GitLab Server Ssetup

Set up the GitLab server using the instructions provided at the following location, specifically the section "Run the GitLab server deployment":

* <a href="../../scripts/gitlab-server/README.md">/scripts/gitlab-server/README.md</a>

# 2. Launchpad Deployment

To deploy the launchpad and create the necessary MSIs, 

TIPS:
* Get the latest version of the Azure CLI if necessary
* Run the following commands before running rover

```bash
alias rover=/tf/rover/rover.sh
export ROVER_RUNNER=true
rover login
```

To deploy the launchpad now, run the following command at the following location:

```bash
rover 
-lz /workspaces/symphony/caf/caf_modules_public/landingzones/caf_launchpad 
-launchpad 
-var-folder /workspaces/symphony/caf/base_config/level0/launchpad 
-level level0 
-env demo 
-a apply 
```

The launchpad should now be created with proper MSI setup for each level. 

Tips:
* You may verify the launchpad resource group in your Azure subscription, e.g. rg-launchpad-security-yog. 
* Specifically, check for the managed identity for level 2, e.g. msi-runner-level-2-dlm. 
* Check for the assigned tags, e.g. environment = demo and level = level2

FYI, the level tag is checked when runners are created

# 3. Clone Repositories

There are 2 options to clone the necessary repositories into the target location:
* Option A (remote to remote): this requires Personal Access Tokens (PATs) for both the source and target repositories
* Option B (local to remote): this requires a PAT only for the target repository

TIPS: 
- Create your Personal Access Token (PAT) on each GitLab location (source and/or target) and make a note of them.
- Set up SSH Keys as needed.
- Use Option B to get the latest current version of the repositories.

For Option A (remote to remote), run the following command at the following location:

```bash
cd scripts/utils/

./clone-repos.sh 
-g reference_app_caf 
-sp <source-pat> 
-sd <source-fqdn> 
-tp <target-pat> 
-td <target-fqdn>
-e <launchpad-environment>
```

The parameters are defined as follows:
* g = GitLab Source Group
* sp = (Source) Personal Access Token
* sd = (Source) Fully Qualified Domain Name
* tp = (Target) Personal Access Token
* td = (Target) Fully Qualified Domain Name
* e = CAF Launchpad Environment, e.g. "demo"

For Option B (local to remote), run the following command at the following location:

```bash
cd scripts/utils/

./clone-repos.sh 
-s /workspaces/symphony/caf 
-tp <target-pat>
-td <target-fqdn>
-e <launchpad-environment>
-d  
-o
```

The parameters are defined as follows:
* s = Local Path for Source
* tp = (Target) Personal Access Token
* td = (Target) Fully Qualified Domain Name
* e = CAF Launchpad Environment, e.g. "demo"
* d = debug flag
* o = overwrite target repo


# 4. Runner Setup

Before you can set up the GitLab runners, you must obtain the parammeter values generated from Step 1 (server setup). Inspect the .json file exported into the /.data folder by the server setup process to observe the values in it, e.g. ./data/gitlab-server.json

```json
{
    "resourceGroup": "<resource-group>",
    "vmName": "<gitlab-server>",
    "vmPublicIp": "1.1.1.1",
    "vmPrivateIp": "<internal-ip>",
    "user": "<gitlab-user>",
    "fqdn": "<server-fqdn>",
    "sshKey": "<ssh-key>",
    "token": "<gitlab-token>"
}
 ```

Next, update ```install.sh``` in ```/scripts/utils``` with values obtained from the .json file.

```bash
declare RESOURCE_GROUP="<resource-group>"
declare GITLAB_TOKEN="<gitlab token>"
declare GITLAB_URL="<server-fqdn>"
declare CERT_PATH=/workspaces/symphony/.data/ssl/server.crt
declare SERVER_INTERNAL_IP="<server-private-ip>"
declare ENVIRONMENT="<environment>"
# declare CONFIG_PATH="../../symphony.yml"
```

NOTE: CONFIG_PATH (for retreiving MSI from config file) is not used by the runner setup when MSI is created with CAF Launchpad deployment


Now, run the following command at the following location:

```
cd scripts/utils/

./install.sh
```

This should invoke ```gitlab-runner-setup.sh```, which has the following parameters:

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

NOTE: The -f flag will invoke the creation of 4 VMs (instead of 1 VM), with 5 runners each. For a quick test, it is easier to leave out the -f parameter for faster results. 5 VMs are configured in full mode to allow one pool of runners per CAF layers 0 to 4.


# 5. Pipelines

TIP: Before you trigger the pipelines, verify that the ```.gitlab-ci.yml``` file in the following location has the base URI set to the GitLab server name.

File: ```/caf/caf_orchestrator/.gitlab-ci.yml```
```YAML
variables:
...
  base_uri: '<gitlab-server>'
```

TIP: In case the pipeline run generates a server access error while trying to reach an inaccessible IP Address, update the value for ```external_url``` in ```gitlab.rb``` on the server.


```bash
ssh gitlab@servername.com

cd /etc/gitlab/
sudo chown gitlab:gitlab gitlab.rb
sudo chmod +x gitlab.rb
```

Edit the file ```gitlab.rb``` using any editor, e.g. VIM

```bash
vim gitlab.rb
```

In the file gitlab.rb, set external_url to the FQDN of your Gitlab server:

```ruby
external_url '<gitlab-server>'
```

Exit the file and save changes, 
e.g.

```bash
<Esc>
:wq
```

Restart your Gitlab server with new configuration

```bash
sudo gitlab-ctl reconfigure
```

Run the pipelines in the GitLab web UI, and troubleshoot any errors as necessary.

