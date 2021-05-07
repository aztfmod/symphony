#!/usr/bin/env bash

#server set up
#./gitlab-server-setup.sh

# values needed from server vm
# declare RESOURCE_GROUP="<server_resource_group>"
# declare GITLAB_TOKEN="<gitlab_server_token>"
# declare GITLAB_URL="<gitlab_server_url>"
# declare CERT_PATH=/workspaces/symphony/.data/ssl/server.crt
# declare SERVER_INTERNAL_IP="10.0.0.4"
# declare ENVIRONMENT="<caf_env>"
# declare CONFIG_PATH="../../symphony.yml"

# invoke runner script
./gitlab-runner-setup.sh \
  -g $RESOURCE_GROUP \
  -gt $GITLAB_TOKEN \
  -gd $GITLAB_URL \
  -c $CERT_PATH \
  -si $SERVER_INTERNAL_IP \
  -e $ENVIRONMENT \
  -cp $CONFIG_PATH \
  -d \
  -f
