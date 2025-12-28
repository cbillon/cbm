#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT=demo
PLUGIN=tool_opcache
DEBUG=false

# for ((i = 0; i < ${#FILES[@]}; i++))
# do
#     echo "${FILES[$i]}"
# done

plugins=($(jq -r ".plugins[].name" projects/demo/demo.json | tr "\n" " "))

echo nb:"${#plugins[@]}"
i=0
IFS=" "
for plugin in ${plugins[*]}
do
    echo "$i" "${plugin}"
    ((++i))
done

success "That's All!"