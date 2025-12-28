#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="$1"
NEW_PLUGIN="$2"
DEBUG=false

info new plugin: "$2"


function get_plugins () {
  
  #in: $PROJECT
  #out: $PLUGINS

  Start "$*"
  if [[ $(jq '.plugins' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json) != null ]]; then
    #PLUGINS=($(jq -r '.plugins[].name' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json | tr "\n" " "))
    PLUGINS=($(jq -r ".plugins[].name" "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json | tr "\n" " "))
  else
    PLUGINS=''
    warn plugin list empty
  fi
  [ "$DEBUG" = true ] && info Nb plugins: "${#PLUGINS[@]}"

  End
}
function add_plugin_project () {

  PROJECT="$1"
  PLUGIN="$2"
  Start "$*"
  # Retrieve plugins already in configuration file
  get_plugins "$PROJECT"
  cd "$DEPOT_MODULES" || exit
  local i error must_update_codebase list
  i=0
  must_update_codebase=0
  error=0

  list=''
  for d in $(ls -l "$DEPOT_MODULES" | awk '{print $9}'); do
    # save plugins not in project configuration file
    if [[ -z $(jq -r '.plugins[].name' /home/cb/cbm/projects/demo/demo.json | grep "$d" ) ]]; then
      ((++i))
      list="$list $d $i OFF"
    fi
  done

  PLUGINS=$(menu --title "Plugins cache" --checklist "Plugin's List" 25 78 16 $list)

  for PLUGIN in "${PLUGINS[@]}"; do
    PLUGIN="${PLUGIN//'"'}"
    [ "$DEBUG" = true ] && info projects plugin add: "$PLUGIN"
    if [[ -z $(jq -r '.plugins[].name' /home/cb/cbm/projects/demo/demo.json | grep "$PLUGIN" ) ]]; then
      jq  -r --arg plugin "$PLUGIN" '.plugins[.plugins| length] |= . + { "name": $plugin }' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json > demo.tmp && mv demo.tmp "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json
    fi 
  done
  must_update_codebase=1
  End
  return "$error"
}


add_plugin_project "$1" "$2"

cat /home/cb/cbm/projects/demo/demo.json

# for ((i = 0; i < ${#FILES[@]}; i++))
# do
#     echo "${FILES[$i]}"
# done

# l=($(jq -r ".plugins[].name" projects/demo/demo.json | tr "\n" " "))

# echo nb:"${#l[@]}"
# i=0
# IFS=" "
# for plugin in ${l[*]}
# do
#     echo "$i" "${plugin}"
#     ((++i))
# done

# for plugin in "${plugins[@]}"; do
#   echo "$plugin"
#   echo ' '
# done