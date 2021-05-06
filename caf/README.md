# CAF sample application

This CAF application is based on the CAF Terraform Landing Zones Starter Sandpit configuration and used for demonstration purposes.

[caf-terraform-landingzones-starter](https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/configuration/sandpit)

## Folder structure

One noticable difference between this folder structure and the starter repo is the organization of deployments into three main configurations instead of by level. This structure allows for pipelines to be run by need and permission. There may be multiple app_* repos against this one CAF deployment. As always, you can adopt your own structure as needed while adhering to the CAF level principles.

- Config Launchpad
  - Level 0 only
  - Teffaform State management storage containers and keyvauls
  - MSIs for Gitlab runner agents to deploy subsequent levels (moving to an CAF runner add-on eventually)
  - Deployed from the devcontainer rover cli via logged in Owner of target subscription
    - Deploy command available in [local.sh](./local.sh)sx

- Config Platform
  - Levels 1, 2 and 3
  - Level 3 resources that are shared, not app specific are deployed here (none present in this sample)

- App *
  - Levels 3, 4
  - Self contained application deployment
  - Custom CAF landing zones and modules (as needed)

- CAF Modules
  - Landing zones imported and unmodified from the main CAF repo
    - [caf-terraform-landingzones](https://github.com/Azure/caf-terraform-landingzones)
    - Imports modules at runtime from the landing zone source defined in the caf_modules/landingzones/caf_*/landingzone.tf
      - [terraform source options](https://www.terraform.io/docs/language/modules/sources.html)
  - Custom landing zone code should be in the app_*/custom_modules folder or new repo to avoid code drift
  - Modules folder for local module reference instead of runtime (as needed)
    - [terraform-azurerm-caf](https://github.com/aztfmod/terraform-azurerm-caf)
    - Use relative path from landing zone source = "../../modules" and no version specification

## Copy to GitLab
Please use the [clone-repos.sh](../scripts/utils/README.md) script to copy all the folders in this path to GitLab as inddividual repos under a parent Group. This will also add the environmnet variables to the Group to allow proper pipeline and MSI execution.
