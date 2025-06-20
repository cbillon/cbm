#!/bin/bash
set -uEo pipefail

exit_handler()
{
    local err=$1 # error status
    local line=$2 # LINENO
    local bash_linenos=($3)
    local bash_sources=($4)
    local command="$5"
    local funcstack=($6)

    echo -e "\n<---"
    echo -e "\tERROR: [${bash_sources[0]} line $line] - command '$command' exited with status: $err"

    if [[ "${funcstack}" == "empty" ]]
    then
        echo -e "--->"
        exit $err
    fi

    local max_idx=$((${#funcstack[@]} - 1))
    local previous_file=""
    for idx in $(seq $max_idx -1 0)
    do
        local current_file=${bash_sources[idx]}
        local display_file=""
        if [[ "${current_file}" != "${previous_file}" ]]
        then
            display_file="[${current_file}] "
        fi

        local t=${bash_linenos[$((idx - 1))]}
        if ((idx == 0))
        then
            t=$line
        else
            t="$t"
        fi

        if [[ -n "${display_file}" ]]
	then
	    echo -e "\t| ${display_file}"
	fi
	
	arrow="| "
	((idx == 0)) && arrow="V "
	echo -e  "\t${arrow}    ${funcstack[${idx}]}:$t"
        previous_file="${current_file}"
    done

    echo -e "--->"
        
    exit $err
}
trap 'exit_handler $? $LINENO "${BASH_LINENO[*]}" "${BASH_SOURCE[*]}" "$BASH_COMMAND" "${FUNCNAME[*]:-empty}"'  ERR
#trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
#IFS=$'\n\t'

#LOGFILE="log.log"
#exec 3>&1 1>"$LOGFILE" 2>&1
#trap "echo 'ERROR: An error occurred during execution, check log $LOGFILE for details.' >&3" ERR
#trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG