#!/bin/bash

LANDING_ZONES_FOLDER="./caf-terraform-landingzones"

if test -d "$LANDING_ZONES_FOLDER"
then
  echo "Landing Zones found..."
else
  echo "Landing Zones couldn't found, Starter Landing Zones are downloading..."

  git clone https://github.com/Azure/caf-terraform-landingzones.git
fi

CONFIG_FOLDER="./caf-terraform-landingzones-starter"

if test -d "$CONFIG_FOLDER"
then
  echo "Landing Zones Configurations found..."
else
  echo "Landing Zones Configurations couldn't found, Starter Landing Zones Configurations are downloading..."

  git clone https://github.com/Azure/caf-terraform-landingzones-starter.git
fi

echo "Running rover to deploy infrastructure..."

environment="demo"

/tf/rover/rover.sh -lz ./caf-terraform-landingzones/landingzones/caf_launchpad \
  -launchpad \
  -var-folder ./configuration/${environment}/level0/launchpad \
  -parallelism 30 \
  -level level0 \
  -env ${environment} \
  -a apply

echo "${environment} environment infrastructure deployed, running tests..."

export TEST="${environment}"

go test -v ./...
