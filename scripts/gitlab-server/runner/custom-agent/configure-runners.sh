#!/usr/bin/env bash

docker build -t gitlab_agent .

declare MSI_ID=$1
declare GITLAB_TOKEN=$2
declare GITLAB_URL=$3
declare GITLAB_AGENT_NAME=$4

echo "MSI_ID=$MSI_ID"
echo "GITLAB_TOKEN=$GITLAB_TOKEN"
echo "GITLAB_URL=$GITLAB_URL"
echo "GITLAB_AGENT_NAME=$GITLAB_AGENT_NAME"

for i in {1..5}; do
  runnerName="$GITLAB_AGENT_NAME-$i" 
  echo "Creating $runnerName"
  docker run -d \
             -e "MSI_ID=$MSI_ID" \
             -e AGENT_TOKEN=$GITLAB_TOKEN \
             -e AGENT_URL=$GITLAB_URL \
             -e LABELS=rover,test, \
             -e WORK_FOLDER=./ \
             -e AGENT_NAME="$runnerName" \
             -e USERNAME=rover gitlab_agent
done
