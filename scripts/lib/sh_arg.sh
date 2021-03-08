#!/usr/bin/env bash

declare -A _SH_ARGUMENTS=()
declare -A _SH_SWITCHES=()
declare -A _SH_TYPES=()
declare -A _SH_AUTOS=()
declare -A _SH_HOOK_FUNCTIONS=()
shArgs.arg(){   
    local variableName=$1
    local shortName=$2
    local longName=$3
    local argType=$4
    local auto=$5
    local hookFunction=$6
    if [ ! -z "$shortName" ]; then
        _SH_SWITCHES[$shortName]=$variableName
    fi

    if [ ! -z "$longName" ]; then
        _SH_SWITCHES[$longName]=$variableName
    fi

    if [ ! -z "$argType" ]; then
        _SH_TYPES[$variableName]=$argType
    else
        _SH_TYPES[$variableName]="PARAMETER"
    fi
    
    if [ "$argType" == "FLAG" ]; then
        _SH_ARGUMENTS[$variableName]=false
    else
        _SH_ARGUMENTS[$variableName]="" 
    fi

    if [ "$auto" == true ]; then
        _SH_AUTOS[$variableName]=true
    else
        _SH_AUTOS[$variableName]=false
    fi

    if [ ! -z "$hookFunction" ]; then
        _SH_HOOK_FUNCTIONS[$variableName]=$hookFunction
    fi
}

_strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

_processFlag() {
    local _varName=$1
    local autoExport=$2
    _SH_ARGUMENTS[$_varName]=true
    if [ "$autoExport" == true ]; then
        eval "$_varName=true"
    fi
}

 _processParameter() {
    local _varValue=1
    local value=$2
    local autoExport=$3
    
    if [[ "$value" == *","* ]]; then
        local _listInput=$value
        local arr
        BFS=$IFS
        IFS=, read -a arr <<<"${_listInput}"
        IFS=$BFS
        listData="${arr[@]}"
        _varValue=$listData
        _SH_ARGUMENTS[$_varName]="$listData"
    else
        _varValue=$value                             
    fi

    _SH_ARGUMENTS[$_varName]=$_varValue
    
    if [ "$autoExport" == true ]; then
        eval "$_varName=\"$_varValue\""
    fi                                            
}

_processSplitData() {
    local name=$1
    local value=$2
    local _varName
    local argType
    local autoExport

    _varName=${_SH_SWITCHES[$name]}    
    if [ ! -z "$_varName" ]; then
        argType=${_SH_TYPES[$_varName]}
        autoExport=${_SH_AUTOS[$_varName]}
        hookFunction=${_SH_HOOK_FUNCTIONS[$_varName]}
        if [ "$argType" == "FLAG" ]; then
            _processFlag "$_varName" "$autoExport"
        else
            _processParameter "$_varName" "$value" "$autoExport"
        fi
        if [ ! -z "$hookFunction" ]; then          
            eval "$hookFunction \"${_SH_ARGUMENTS[$_varName]}\""                    
        fi                    
    fi  
}

_trim() {
    local value=$1
    echo $value | xargs
}

_processLine(){
    local input_string=$1
    local firstChar="${input_string:0:1}"
    if [ "$firstChar" != "-" ]; then
      return 0 # not a switch exit
    fi
    
    local size=${#input_string}  
    local spaceIndex=$(_strindex "$input_string" " ")
    local name=${input_string:0:spaceIndex}
    local value=${input_string:spaceIndex+1:size}
    local valueSize=${#input_string} 
    value=$(_trim "$value")
    if [ "$spaceIndex" == "-1" ]; then
        name=$value
        value=""
    fi
 
    if [[ "$name" == *"="* ]]; then    
        name=${input_string:0:size}
        BFS=$IFS
        IFS='='
        read -ra arr <<<"$name"
        IFS=$BFS
        name=${arr[0]}
        value=${arr[1]}
        value=$(_trim "$value")
    fi
    _processSplitData "$name" "$value"
}

shArgs.parse(){
    local input_string=$@
    local char=""
    local tmp=""

    for (( i=0; i<${#input_string}; i++ )); do
        char=${input_string:$i:1}    
        if [ "$char" == "-" ]; then
          if [ ! -z "$tmp" ]; then
            _processLine "$tmp"
            tmp=""
          fi
          if [ "${input_string:$i:2}" == "--" ]; then
            tmp+="$char"
            i=$((i+1))
          fi
        fi
        tmp+="$char"
    done   
    if [ ! -z "$tmp" ]; then
        _processLine "$tmp"
        tmp=""
    fi     
}

shArgs.val(){
   echo ${_SH_ARGUMENTS[$1]}
}