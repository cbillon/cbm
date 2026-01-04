#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-demo}"
DEBUG="${2:-false}"

info plugin: "$PROJECT" debug: "$DEBUG"

function rm_plugin () {
  Start "$*"
  local i list
  
  get_plugins "$PROJECT"
  
  i=0
  list=''
  for PLUGIN in "${PLUGINS[@]}"
  do
    info plugin: "$PLUGIN"
    list="$list $i $PLUGIN OFF"
    ((++i))
  done

  n=$(menu --title "Plugins cache" --radiolist "Plugin's List" 25 78 16 $list)
   
  PLUGIN=$(jq -r ".plugins[$n].name" "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  jq "del(.plugins[$n])|." "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json > "$PROJECT".tmp && mv "$PROJECT".tmp "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json

  suppress_plugin "$PLUGIN"

  End
}

get_project_conf "$PROJECT"
rm_plugin "$@"