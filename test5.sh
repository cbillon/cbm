#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PLUGIN="$1"
DEBUG=true

info plugin: "$PLUGIN" debug: "$DEBUG"

get_plugin_observed_state () {
  
  Start "$*"
  PLUGIN="$1"
  STATE_TYPE=null
  STATE=null
  get_plugin_dir "$PLUGIN"
  
  # plugin already installed
  cd "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME" || exit
  [[ $(grep .gitrepo -e 'PLUGIN_STATE_TYPE=') =~ ^.*PLUGIN_STATE_TYPE=(.*)$ ]] && STATE_TYPE="${BASH_REMATCH[1]}"
  [[ $(grep .gitrepo -e 'PLUGIN_DESIRED_STATE=') =~ ^.*PLUGIN_DESIRED_STATE=(.*)$ ]] && STATE="${BASH_REMATCH[1]}"
  
  [ "$DEBUG" = true ] && info state type in plugin: "$STATE_TYPE" state: "$STATE"
  End
}

codebase_need_update () {
  
  Start "$*"
  PLUGIN="$1"
  get_plugin_dir "$PLUGIN"
  
  if [ -d "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME" ]; then

    get_plugin_desired_state "$PLUGIN"

    get plugin_observed_state "$PLUGIN"
    if [ "$PLUGIN_STATE_TYPE" == "$STATE_TYPE" ] && [ "$PLUGIN_DESIRED_STATE" == "$STATE" ]; then
      success "$PLUGIN" type "$STATE_TYPE" state "$PLUGIN_DESIRED_STATE" OK
    else
      install_plugin "$PLUGIN"
    fi
  else
    info "$PLUGIN" not installed
    install_plugin "$PLUGIN"
  fi

  End
}
