#!/usr/bin/env bash

source ../scripts/lib/shell_logger.sh
source ../scripts/lib/sh_arg.sh

declare LANDING_ZONES_FOLDER=""
declare CONFIG_FOLDER=""
declare ENVIRONMENT=""

shArgs.arg "LANDING_ZONES_FOLDER" -z --zones PARAMETER true
shArgs.arg "CONFIG_FOLDER" -c --config PARAMETER true
shArgs.arg "ENVIRONMENT" -e --environment PARAMETER true

shArgs.parse $@

check_inputs() {
  _debug_line_break
  _debug " Landing Zones Folder : $LANDING_ZONES_FOLDER"
  _debug "        Config Folder : $CONFIG_FOLDER"
  _debug "          Environment : $ENVIRONMENT"
  _debug "                Debug : $DEBUG_FLAG"
  _debug_line_break

  if [ -z "${LANDING_ZONES_FOLDER}" ]; then
    _error "Landing Zones Folder is required!"
    usage
  fi
  if [ -z "${CONFIG_FOLDER}" ]; then
    _error "Config Folder is required!"
    usage
  fi
  if [ -z "${ENVIRONMENT}" ]; then
    _error "Environment is required!"
    usage
  fi
}

check_inputs

if test -d "$LANDING_ZONES_FOLDER"
then
  _information "Landing Zones found..."
else
  _error "Landing Zones couldn't found, exiting..."

  exit 1
fi

if test -d "$CONFIG_FOLDER"
then
  _information "Landing Zones Configurations found..."
else
  _error "Landing Zones Configurations couldn't found, exiting..."

  exit 1
fi

_information "Running rover to deploy infrastructure..."

/tf/rover/rover.sh -lz "${LANDING_ZONES_FOLDER}/landingzones/caf_launchpad" \
  -launchpad \
  -var-folder "${CONFIG_FOLDER}/${ENVIRONMENT}/level0/launchpad" \
  -parallelism 30 \
  -level level0 \
  -env ${ENVIRONMENT} \
  -a apply

_information "${ENVIRONMENT} environment infrastructure deployed, running tests..."

export ENVIRONMENT=${ENVIRONMENT}

export RESOURCE_GROUP_NAME="${PREFIX}-rg-launchpad-level0"

go test -v ./...
