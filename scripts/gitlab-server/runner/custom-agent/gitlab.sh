#!/bin/bash

set -Ee

function finally {
  echo "Un-register the runner."
  /usr/local/bin/gitlab-runner unregister --all-runners
}

trap finally EXIT SIGTERM

# perform login using msid
# in pipeline we are now able to auth via simply invoking ` az login --identity `
az login --identity -u ${MSI_ID} --allow-no-subscriptions

if [ -n "${AGENT_TOKEN}" ]; then
  echo "Found AGENT_TOKEN variable for GitLab. Skipping KeyVault Fetch"
else
  echo "Fetching GitLab AGENT_TOKEN using MSI ${MSI_ID} from KeyVault: ${AGENT_KEYVAULT_NAME}"
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
