WIP:


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
declare GITLAB_TOKEN="63kfPMczhV328d7xo6Ms"
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




