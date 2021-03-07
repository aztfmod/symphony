#!/bin/bash

set -Ee

function finally {
  echo "Un-register the runner."
  /usr/local/bin/gitlab-runner unregister --all-runners
}

echo "******************** HERE ***********"

trap finally EXIT SIGTERM

if [ -n "${AGENT_TOKEN}" ]; then
  echo "Connect to Azure AD using AGENT_TOKEN"
else
  echo "Connect to Azure AD using MSI ${MSI_ID}"
  az login --identity -u ${MSI_ID} --allow-no-subscriptions

  # Get PAT token from KeyVault if not provided from the VSTS_AGENT_INPUT_TOKEN
  AGENT_TOKEN=$(az keyvault secret show -n ${AGENT_KEYVAULT_SECRET} --vault-name ${AGENT_KEYVAULT_NAME} -o json | jq -r .value)
fi

LABELS+=$(cat /tf/rover/version.txt)

git clone --branch 2101.0.0 https://github.com/Azure/caf-terraform-landingzones.git /tf/caf/public

gitlab-runner register \
  --non-interactive \
  --url "${AGENT_URL}" \
  --registration-token "${AGENT_TOKEN}" \
  --name "${AGENT_NAME}" \
  --executor "shell" \
  --shell "bash" \
  --request-concurrency 1 \
  --tag-list ${LABELS}

  /usr/local/bin/gitlab-runner run
