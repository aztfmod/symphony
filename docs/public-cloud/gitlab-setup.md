# Gitlab Setup Guide for CAF Sample App

This document outlines the steps necessary to set up a sample CAF (Cloud Adoption Framework) application in GitLab. 

To summarize:

0. Clone the [symphony](https://github.com/aztfmod/symphon) repo.
  - For now use the following branch: [/davesee/bump_versions](https://github.com/aztfmod/symphony/tree/davesee/bump_versions)
1. Set up the GitLab server with ```gitlab-server-setup.sh```
2. Set up SSH Keys and clone repostories using ```clone-repos.sh```
3. Deploy the launchpad landing zone manually to set up MSIs, using ```rover```
4. Set up the Gitlab runners with ```install.sh```
5. Run pipelines in Gitlab and troubleshoot as necessary

# 1. GitLab Server Ssetup

Set up the GitLab server using the instructions provided at the following location, specifically the section "Run the GitLab server deployment":

* <a href="../../scripts/gitlab-server/README.md">/scripts/gitlab-server/README.md</a>

# 2. Clone Repositories

There are 2 options to clone the necessary repositories into the target location:
* Option A (remote to remote): this requires Personal Access Tokens (PATs) for both the source and target repositories
* Option B (local to remote): this requires a PAT only for the target repository

TIPS: 
- Create your Personal Access Token (PAT) on each GitLab location (source and/or target) and make a note of them.
- Set up SSH Keys as needed.
- Use Option B to get the latest current version of the repositories.

For Option A (remote to remote), run the following command at the following location:

```
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

```
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

# 3. Launchpad Deployment

To deploy the launchpad and create the necessary MSIs, 

TIPS:
* Get the latest version of the Azure CLI if necessary
* Run the following commands before running rover

```
alias rover=/tf/rover/rover.sh
export ROVER_RUNNER=true
rover login
```

To deploy the launchpad now, run the following command at the following location:

```
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

```
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

NOTE: The -f flag will invoke the creation of 5 VMs (instead of 1 VM), with 5 runners each. For a quick test, it is easier to leave out the -f parameter for faster results. 5 VMs are configured in full mode to allow one pool of runners per CAF layers 0 to 4.


# 5. Pipelines

TIP: Before you trigger the pipelines, verify that the ```.gitlab-ci.yml``` file in the following location has the base URI set to the GitLab server name.

File: /caf/caf_orchestrator/.gitlab-ci.yml
```
variables:
  environment: 'demo'
  application: 'argocd'
  landingzone_key : 'cluster_aks'
  cluster_key: 'cluster_re1'
  base_uri: '<gitlab-server>'
```

TIP: In case the pipeline run generates a server access error, run the following command after you SSH into the server.


```
ssh gitlab@servername.com

cd /etc/gitlab/
sudo chown gitlab:gitlab gitlab.rb
sudo chmod +x gitlab.rb
```

Edit the file ```gitlab.rb``` using any editor, e.g. VIM

```
vim gitlab.rb
```

In the file gitlab.rb, set external_url to the FQDN of your Gitlab server:

```
external_url '<gitlab-server>'
```

Exit the file and save changes, 
e.g.

```
<Esc>
:wq
```

Restart your Gitlab server with new configuration

```
sudo gitlab-ctl reconfigure
```

Run the pipelines in the GitLab web UI, and troubleshoot any errors as necessary.




### NOTES TO DELETE ###

-> server setup

-> runner setup

WIP: use the following branch for now
* https://github.com/aztfmod/symphony/tree/davesee/bump_versions

go to /scripts/utils
/clone-repos.sh

get ready to run command

in Gitlab server
top-right
profile icon
Preferences

left panel
Access Tokens
Add a personal access token
set any name + expiry date
scopes: api, read_repository, write_repository
copy PAT1 value for later

also left panel
SSH keys
add in SSH key from dev env

to get SSH key
cat ~/.ssh/id_rsa.pub

copy value, e.g.
ssh-rsa ABCDEF ... 

copy over to SSH Keys in gitlab
also set Title + Expiry date

now copy over projects
e.g. from rguthrie server

log in to reference gitlab instance
on left panel
go to Access Tokens
create new PAT with name, expiry date
scopes: api, read_repository, write_repository
copy PAT2 value for later

also on left panel
go to SSH Keys
add in previously created SSH key
add Title + Expiration date

now run clone_repos with source and target pats

SAMPLE RUN (from gitlab source):
--
./clone-repos.sh 
-g reference_app_caf 
-sp at5_1VxFaNNsBdQu5Nrm 
-sd rguthrie-gitlab-ce.eastus.cloudapp.azure.com 
-tp PqoT7mBbnbQCqRQHd-WJ 
-td my-gitlab-serversc.eastus.cloudapp.azure.com 
-e demo

NOTE: may need to set permissions first
sudo chmod +x clone_repos.sh

NEW VERSION (from local source):
--
./clone-repos.sh 
-s /workspaces/symphony/caf 
-tp PqoT7mBbnbQCqRQHd-WJ 
-td my-gitlab-serversc.eastus.cloudapp.azure.com/ 
-e demo 
-d  
-o
--

this will copy all repos from source to target
verify all projects available
- <list>
check orchestrator project, .gitlab-ci.yml file
verify that target server is mentioned in script params

---



---

now run install.sh for runner setup
verify params from .json file created in server setup

e.g.
```
declare RESOURCE_GROUP="gitlab-testsc-rg"
declare GITLAB_TOKEN="<your gitlab token>"
declare GITLAB_URL="my-gitlab-serversc.eastus.cloudapp.azure.com"
declare CERT_PATH=/workspaces/symphony/.data/ssl/server.crt
declare SERVER_INTERNAL_IP="10.0.0.4"
declare ENVIRONMENT="demo"
# declare CONFIG_PATH="../../symphony.yml"
```

(switch to generate_msi branch)
observe /scripts/gitlab-server/install.sh
update params in install.sh

deploy launchpad manually
verify docker is running
open project in dev container

Get latest AZ CLI with az upgrade
v2.22.1 at the time of this writing

run commands before running rover
alias rover=/tf/rover/rover.sh
export ROVER_RUNNER=true
rover login

some code changes...

/caf/caf_modules_public/landingzones/caf_launchpad/landingzone.tf
for module launchpad, set source and version
```
  source = "git@github.com:aztfmod/terraform-azurerm-caf.git?ref=davesee-msi_tags"
  # version = "~>5.1.0"
```
(not needed when merged to master)


/caf/caf_modules_public/landingzones/caf_launchpad/main.tf
azuread, v change from 1.0.0 to 1.4.0
azurecaf, v change from 1.1.0 to 1.2.0

/caf/base_config/level0/launchpad/configuration.tfvars
passthrough = false
random_length = 3
prefix = ""
inherit_tags = true

this ensure that msiId values in symphony.yml gets populated automatically

In dev container, generate SSH key to add to aztfmod/terraform-azurerm-caf
> ssh-keygen
observe output
> cat ~/.ssh/id_rsa.pub
observe key value, e.g. 
ssh-rsa ABCDEF...
copy to github SSH keys in profile, SSH keys


run rover for launchpad
rover 
-lz /workspaces/symphony/caf/caf_modules_public/landingzones/caf_launchpad 
-launchpad 
-var-folder /workspaces/symphony/caf/base_config/level0/launchpad 
-level level0 
-env demo 
-a apply

launchpad should now be created with proper MSI setup for each level
verify launchpad resource group in Azure subscription
e.g. rg-launchpad-security-yog
check managed identity for level 2
e.g. msi-runner-level-2-dlm
check tags on left
environment = demo and level = level2

level is checked when runners are created

verification using code from find_msi_by_level() in gitlab-runner-setup.sh

> az identity list --query "[?tags.level == 'level2' && tags.environment == 'demo']".clientId -o tsv)
 
verify objectid is client id of level 2 MSI 

NOW -> run install.sh with ENVIRONMENT set to demo, in full mode


BEFORE running pipeline
---
update YAML file in my repo that I got from cloned Richard's repo 
update tags e.g. -gitlab-runner-1
update MSI IDs by level, e.g. ${MSI_ID_01}

--

in .gitlab-ci.yml file, verify 
base_uri: 'servername.com'


--

in case unable to access?
SSH into gitlab server1!

--

```
ssh gitlab@servername.com
```

--

cd /etc/gitlab/
sudo chown gitlab:gitlab gitlab.rb
sudo chmod +x gitlab.rb
vim gitlab.rb
external_url 'servername.com'
Esc :wq (to save changes)
sudo gitlab-ctl reconfigure (restarts gitlab server with new config)

--


--

-> now run pipelines!

--

YML sample:

---

```
foundations:
  stage: foundations
  tags:
    - gitlab-runner-1
  script:
...
      az login --identity --username ${MSI_ID_01}
...

shared_services:
  stage: shared_services
  tags:
    - gitlab-runner-2
  script:
...
      az login --identity --username ${MSI_ID_02}
...

networking:
  stage: networking
  tags:
    - gitlab-runner-2
  script:
...
      az login --identity --username ${MSI_ID_02}
...

#####################################################################
# APP Deployment
#####################################################################

aks:
  stage: aks
  tags:
    - gitlab-runner-3
  script:
...
      az login --identity --username ${MSI_ID_03}
...

argocd:
  stage: argocd
  tags:
    - gitlab-runner-4
  script:
...
      az login --identity --username ${MSI_ID_04}
...
```
--


run pipelines
-- > done!




