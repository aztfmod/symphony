# Sovereign Cloud Guide for Project Symphony

This document highlights the steps necessary to test this project with a sovereign cloud.

# OPTIONAL: Register new cloud

0. Before running ```az cloud show``` to export the current cloud's details, run it once to view the current cloud details in the Terminal. If necessary, run ```az cloud set``` to set the desired cloud as the active cloud.
    * ```az cloud show -o table```

1. Run the following command to export the current cloud's details into a .json file
    * ```az cloud show > cloud.json```

1. Delete the following values from the generated .json file: isActive, name and profile, since these 3 values will be automatically assigned during the ```az cloud register``` process.

1. Run the following command, using the revised .json file:
    * ```az cloud register -n USSec --cloud-config @"cloud.json"```

1. Log out of current cloud
    * ```az logout```

1. Set newly registered cloud
    * ```az cloud set -n USSec```

1. Log in to newly registered cloud
    * ```az login```


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
    * e.g. region1 = "usgovvirginia"
    * e.g. region2 = "usgovtexas"
    * Ref: https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-get-started-connect-with-ps#get-current-regions

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
  -c azure_stack
```

NOTE: If cloud_name (provided by -c parameter) is NOT found, $AZURE_ENVIRONMENT value is used to set ARM_ENVIRONMENT to the corresponding Terraform environment value. If found, ARM_ENVIRONMENT is set to that cloud name.

