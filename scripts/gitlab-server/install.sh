#!/usr/bin/env bash

#server set up
#./gitlab-server-setup.sh

# values needed from server vm
declare RESOURCE_GROUP="server_group"
declare GITLAB_TOKEN="<token>"
declare GITLAB_URL="<gitlab server url>"
declare CERT_PATH=~/projects/caf/symphony/.data/gitlab.crt
declare SERVER_INTERNAL_IP="10.0.1.4"

# invoke runner script
./gitlab-runner-setup.sh \
    -g $RESOURCE_GROUP \
    -c $CERT_PATH \
    -gt $GITLAB_TOKEN \
    -gd $GITLAB_URL \
    -si $SERVER_INTERNAL_IP \
    -cp ../../symphony.yml \
    -f \
    -d \


