#!/usr/bin/env bash

source ../scripts/lib/shell_logger.sh
source ../scripts/lib/sh_arg.sh
source ../scripts/lib/utils.sh
source ./utils.sh

declare LANDING_ZONES_FOLDER=""
declare CONFIG_FOLDER=""
declare ENVIRONMENT=""
declare DEBUG_FLAG=false
declare CREATE_ENV=false

shArgs.arg "LANDING_ZONES_FOLDER" -z --zones PARAMETER true
shArgs.arg "CONFIG_FOLDER" -c --config PARAMETER true
shArgs.arg "ENVIRONMENT" -e --environment PARAMETER true
shArgs.arg "CREATE_ENV" -ce --create-env FLAG true
shArgs.arg "DEBUG_FLAG" -d --debug FLAG true

shArgs.parse $@

main() {
  export_arm_subscription_id

  check_inputs

  if [ $CREATE_ENV == true ]; then
    _information "Running rover to deploy infrastructure for environment ${ENVIRONMENT}..."

    deploy_environment
  else
    _information "Proceeding with existing environment ${ENVIRONMENT}"
  fi

  find_and_export_prefix

  export ENVIRONMENT=${ENVIRONMENT}

  go test -v ./...
}

main
