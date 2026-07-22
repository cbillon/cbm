#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

function get_cache_plugins () {
  Start "$*"
  local error=0
  
  End
  return "$error"        
}

info That s All !

PROJECT="${1:-new52}"
DEBUG=true
PLUGIN="${2:-tool_datewatch}"

info PROJECT: "$PROJECT" debug: "$DEBUG" plugin: "$PLUGIN"

get_project_conf "$PROJECT"

is_official_plugin "$PLUGIN" 