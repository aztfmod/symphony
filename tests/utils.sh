usage() {
  local azStatusMessage

  if [ -x "$(command -v az)" ]; then
    azStatusMessage=$(_success "installed - you're good to go!")
  else
    azStatusMessage=$(_error "not installed")
  fi

  _helpText="
  Usage: $me
  -e  | --env <environment name> (Required) Name of the CAF environment where the launchpad was deployed to.    
  -ce | --create-environment     (Optional) Create a new environment or use an existing caf environment.
  -z  | --zones <lz Path>        (required only when creating an env) Path to the Landing Zones folder.
  -c  | --config <config path>   (required only when creating an env) Path to the configs folder.
  -d  | --debug                  Turn debug logging on.

   dependencies:
   -az $azStatusMessage"

  _information "$_helpText" 1>&2

  exit 1
}

check_inputs() {
  _debug_line_break
  _debug "           Subscription Id : $ARM_SUBSCRIPTION_ID"
  _debug "               Environment : $ENVIRONMENT"
  _debug "        Create Environment : $CREATE_ENV"
  _debug "      Landing Zones Folder : $LANDING_ZONES_FOLDER"
  _debug "             Config Folder : $CONFIG_FOLDER"
  _debug "                     Debug : $DEBUG_FLAG"
  _debug_line_break

  if [ $CREATE_ENV == true ]; then
    if [ -z "${LANDING_ZONES_FOLDER}" ]; then
      _error "Landing Zones Folder is required!"
      usage
    fi
    if [ -z "${CONFIG_FOLDER}" ]; then
      _error "Config Folder is required!"
      usage
    fi
  fi

  if [ -z "${ENVIRONMENT}" ]; then
    _error "Environment is required!"
    usage
  fi
}

check_valid_folder_paths() {
  if test -d "$LANDING_ZONES_FOLDER"; then
    _information "Landing Zones found..."
  else
    _error "Landing Zones path not found, exiting..."
    exit 1
  fi

  if test -d "$CONFIG_FOLDER"; then
    _information "Landing Zones Configurations found..."
  else
    _error "Landing Zones Configurations path not found, exiting..."
    exit 1
  fi
}

deploy_environment() {
  check_valid_folder_paths

  /tf/rover/rover.sh -lz "${LANDING_ZONES_FOLDER}/landingzones/caf_launchpad" \
    -launchpad \
    -var-folder "${CONFIG_FOLDER}/${ENVIRONMENT}/level0/launchpad" \
    -parallelism 30 \
    -level level0 \
    -env ${ENVIRONMENT} \
    -a apply

  _information "${ENVIRONMENT} environment infrastructure deployed, running tests..."
}

export_arm_subscription_id() {
  export ARM_SUBSCRIPTION_ID=$(az account show | jq -r '.id')
}

find_and_export_prefix () {
  rgName=$(az group list --query "[?tags.environment=='$ENVIRONMENT' && tags.landingzone].{Name:name}" | jq -r "first(.[].Name)")

  prefix=${rgName%-rg-launchpad*}

  export PREFIX=$prefix

  _debug "Prefix: $PREFIX"
}
