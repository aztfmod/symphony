#!/bin/bash

function main() {

  while IFS="=" read key value; do
    export TF_VAR_$key=$value
  done < <(az cloud show | jq -r ".suffixes * .endpoints|to_entries|map(\"\(.key)=\(.value)\")|.[]")

  env | sort
  echo "$TF_VAR_sqlServerHostname"

}

main
