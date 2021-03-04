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

shArgs.parse(){
    local _varName
    local argType
    local autoExport
    while [[ "$#" -gt 0 ]]
    do
        case $1 in
            *)   
                _varName=${_SH_SWITCHES[$1]}      
         
                if [ ! -z "$_varName" ]; then
                    argType=${_SH_TYPES[$_varName]}
                    autoExport=${_SH_AUTOS[$_varName]}
                    hookFunction=${_SH_HOOK_FUNCTIONS[$_varName]}
                    if [ "$argType" == "FLAG" ]; then
                        _SH_ARGUMENTS[$_varName]=true
                        if [ "$autoExport" == true ]; then
                            eval "$_varName=true"
                        fi
                    else
                        _SH_ARGUMENTS[$_varName]=$2
                        if [ "$autoExport" == true ]; then
                            eval "$_varName=$2"
                        fi
                        shift
                    fi
                    if [ ! -z "$hookFunction" ]; then          
                        eval "$hookFunction \"${_SH_ARGUMENTS[$_varName]}\""                    
                    fi                    
                fi                
                ;; 
        esac
        shift
    done

}

shArgs.val(){
   echo ${_SH_ARGUMENTS[$1]}
}