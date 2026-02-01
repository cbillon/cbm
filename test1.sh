#!/bin/bash

# source includes/env.cnf
# source includes/functions.cfg
# source includes/bash_strict.sh
validate_option() {
    local error=0 
    local option="$1" 
    local provided_value="$2"   
    shift 2  
    local valid_options="$*"    
    [[ "$provided_value" =~ $(echo ^\("$valid_options"\)$| tr ' ' '|') ]] &&  eval "$option=\${BASH_REMATCH[1]}" || { option='';error=1; echo invalid option "$provided_value";}
    
    return "$error"
}

validate_option v only_file1 terminal_or_file terminal_and_file only_file && echo v: "$v"