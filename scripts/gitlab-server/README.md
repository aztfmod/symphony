# Configure a gitlab environment that supports CAF/Lucidity Development

## Pre-requisites

- Create a DNS entry (doc it)
- Generate a certificate for the dns entry with letsencrypt (doc it)
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
