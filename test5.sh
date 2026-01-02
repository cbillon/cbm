#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PLUGIN="$1"
MOODLE_VERSION="$2"
DEBUG="${3:-false}"


function is_moodleversion_supported () {  
  # $1 PLUGIN
  # $2 MOODLE_VERSION
  # out if PLUGIN supports MOODLE_VERSION
  # VCS_URL
  # DOWNLOAD_URL
  Start "$*"  
  local error vcs download 
  error=0
  PLUGIN="$1"
  MOODLE_VERSION="$2"

  VCS_URL=null
  DOWNLOAD_URL=null
  
  jq -r --arg plugin  "$PLUGIN" '.plugins|map(select(.component == $plugin)) | .[]' "$RACINE"/pluglist.json > "$RACINE"/tmp.json
  if [[ $(jq '.id' "$RACINE"/tmp.json) ]]; then 
    VCS_URL=$(jq -r '.source' "$RACINE"/tmp.json)
    PLUGIN_MOODLE_VERSION=$(jq -r '[.versions[]| {(.version) : (.supportedmoodles[].release)} ]' "$RACINE"/tmp.json | grep "$MOODLE_VERSION" | sort -nr | grep -E -o  "([0-9]{10})" | cut -f 1 -d " ") || true
    [[ -n "$PLUGIN_MOODLE_VERSION" ]] && success "$PLUGIN": "$MOODLE_VERSION" supported || { error=1; error "$PLUGIN" not support Moodle version "$MOODLE_VERSION"; }
    vcs=$(jq -r '.versions[]|{(.supportedmoodles[].release) : .vcsrepositoryurl}' ./tmp.json | grep "$2" | head -n 1) || true
    [[ -n "$vcs" ]] && VCS_URL="$vcs"
    download=$(jq -r '.versions[]|{(.supportedmoodles[].release) : .downloadurl}' ./tmp.json | grep "$2") || true    
    if [[ "$download" =~ ^.*' '(.*)$ ]]; then
      DOWNLOAD_URL="${BASH_REMATCH[1]}"
    else
      DOWNLOAD_URL=null
      error no value for download url
      error=1
    fi
  else
    error "$PLUGIN"  not in official repository
    error=1 
  fi
    
  [ "$DEBUG" = true ] && info vcs "$vcs" download: "$download"
  
  info VCS URL: "$VCS_URL" DOWNLOAD URL: "$DOWNLOAD_URL"
  
  End
  return
}


info plugin: "$PLUGIN" debug: "$DEBUG"

is_moodleversion_supported "$PLUGIN" "$MOODLE_VERSION"

