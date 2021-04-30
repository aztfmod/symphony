# Public Cloud Guide for Project Symphony

This document highlights the steps necessary to test this project with a public cloud.

Rover is available at: 
* https://github.com/aztfmod/rover/blob/master/scripts/rover.sh

# Review & Prepare

1. Verify Azure Public Portal login in a web browser:
    * Portal: https://portal.azure.com/

1. In the Azure Portal, verify that the logged-in user has owner privileges on the Azure subscription

1. Verify that ```az login``` works in the VS Code Terminal.
    * ```az login```

1. Verify that ```az cloud show --query name -o tsv``` echoes the string value ```AzureCloud```
    * Run  ```az cloud show --query name -o tsv```
    * e.g. Observe ```AzureCloud```

1. If ```AzureCloud``` is not set, then set the current cloud with the following commmand:
    * ```az cloud set -n AzureCloud```

# Set up for testing

1. Start with the rover repo from the aztfmod org on GitHub.
    * Rover on Github: https://github.com/aztfmod/rover

1. Get the landing zones starter branch from the caf-terraform-landingzones-starter repo in the Azure org: 
    * ```git clone https://github.com/Azure/caf-terraform-landingzones-starter.git /tf/caf/public/config```

1. Browse the starter configuration readme at:
    * https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/configuration

1. Clone the public landing zones repo from the ```2102.0.1``` branch (subject to change, see aforementioned starter configuration readme), into a subfolder:
    * ```git clone --branch 2102.0.1 https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public/landingzones```

1. Set the primary/backup regions in ```configuration.tfvars``` for the environment's landing zone's configuration, e.g. launchpad landing zone in demo environment: 
    * ```/public/config/configuration/demo/level0/launchpad/configuration.tfvars```
    * e.g. region1 = "eastus"
    * e.g. region2 = "eastus2"

1. OPTIONAL: To see a list of valid regions, run the following command:
    * ```az account list-locations -o table```

1. At the terminal, set the following variable to assign the desired environment, e.g. demo
    * ```export environment=demo```

1. Browse the demo configuration readme at:
    * https://github.com/Azure/caf-terraform-landingzones-starter/tree/starter/configuration/demo

e.g.
```
rover -lz /tf/caf/public/landingzones/landingzones/caf_launchpad \
  -launchpad \
  -var-folder /tf/caf/public/config/configuration/${environment}/level0/launchpad \
  -parallelism 30 \
  -level level0 \
  -env ${environment} \
  -a [plan|apply|destroy]
```

NOTE: Since the cloud_name (which can be provided by the optional -c parameter) is NOT used  here, $AZURE_ENVIRONMENT value is used to set ARM_ENVIRONMENT to the corresponding Terraform environment value. 

