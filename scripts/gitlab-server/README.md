# Configure a gitlab environment that supports CAF/Lucidity Development

- Steps to complete buildout
  - Run the gitlab server deployment [gitlab-server-setup.sh](./gitlab-server-setup.sh)
  - SSH on to server and run server config [Scripts in configure-server](./configure-server)
    - [configure-gitlab.sh](./configure-server/configure-gitlab.sh)
    - [fetch-gitlab-token.sh](./configure-server/fetch-gitlab-token.sh)
    - [create-account(s).sh](./configure-server/create-account.sh)
    - [create-environment(s).sh](./configure-server/create-environment.sh)
  - Run runner deployment [gitlab-runner-setup.sh](./gitlab-runner-setup.sh)
- Example Commands
  - ```./gitlab-server-setup.sh  -g gitlab-test-rg -l westus2 -i "50.35.50.113 76.95.182.203 50.47.105.108" -c rguthrie-gitlab-server -d```
  - ```./scp-to-server.sh -f rguthrie-gitlab-server.westus2.cloudapp.azure.com -s ./configure-server -d -r```
  - ```./configure-gitlab.sh -f rguthrie-gitlab-server.westus2.cloudapp.azure.com -i 52.183.70.115 -p Thund3rd0m3! -d```

## Pre-requisites

- Create a DNS entry (doc it)

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
