#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT=demo
DEBUG=false

ret=$(jq '.version' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)

[[ "$ret" == null ]]&& echo "$ret" valeur null

echo ret : "$ret"

ret=''

[[ "$ret" == null ]]&& echo "$ret" valeur null

echo ret : "$ret"