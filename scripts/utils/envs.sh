#!/bin/bash

function main() {

  echo -e "LZ Locals:\n"

  while IFS="=" read key value; do
    echo "$key = var.$key"      # Landing Zone local.cloud.tf entries
    export "TF_VAR_$key=$value" # Rover env vars
  done < <(az cloud show | jq -r ".suffixes * .endpoints|to_entries|map(\"\(.key)=\(.value)\")|.[]")

  echo -e "\nLZ Variables:\n"

  while IFS="=" read key value; do
    echo "variable \"$key\" {" # Landing Zone variables.cloud.tf entries
    echo "  default = {}"
    echo "}"
  done < <(az cloud show | jq -r ".suffixes * .endpoints|to_entries|map(\"\(.key)=\(.value)\")|.[]")

  echo -e "\nLZ Variables with values to test:\n"

  while IFS="=" read key value; do
    echo "variable \"$key\" {" # Landing Zone variables.cloud.tf entries
    echo "  default = \"$value\""
    echo "}"
  done < <(az cloud show | jq -r ".suffixes * .endpoints|to_entries|map(\"\(.key)=\(.value)\")|.[]")

  echo -e "\nModule Variables:\n"

  while IFS="=" read key value; do
    echo "$key = try(var.cloud.$key, {})"
  done < <(az cloud show | jq -r ".suffixes * .endpoints|to_entries|map(\"\(.key)=\(.value)\")|.[]")

  # env | sort
  # echo "$TF_VAR_sqlServerHostname"
}

main
