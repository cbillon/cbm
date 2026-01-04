#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

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
    [ "$DEBUG" = true ]&& info MOODLE_VERSION: "$MOODLE_VERSION"
    PLUGIN_MOODLE_VERSION=$(jq -r '[.versions[]| {(.version) : (.supportedmoodles[].release)} ]' "$RACINE"/tmp.json | grep -E ': '"$MOODLE_VERSION" | sort -nr | grep -E -o  "([0-9]{10})" | cut -f 1 -d " ") || true
    [ "$DEBUG" = true ]&& info PLUGIN_MOODLE_VERSION "$PLUGIN_MOODLE_VERSION"
    [[ -n "$PLUGIN_MOODLE_VERSION" ]] && success "$PLUGIN": "$MOODLE_VERSION" supported || { error=1; error "$PLUGIN" not support Moodle version "$MOODLE_VERSION"; }
    vcs=$(jq -r '.versions[]|{(.supportedmoodles[].release) : .vcsrepositoryurl}' "$RACINE"/tmp.json | grep "$2" | head -n 1) || true
    if [[ "$vcs" =~ ^.*' "'(.*)'"'$ ]]; then
      VCS_URL="${BASH_REMATCH[1]}"
    else
      VCS_URL=null
      error no value for vcs url
      error=1
    fi
    download=$(jq -r '.versions[]|{(.supportedmoodles[].release) : .downloadurl}' "$RACINE"/tmp.json | grep ': '"$MOODLE_VERSION") || true    
    if [[ "$download" =~ ^.*' "'(.*)'"'$ ]]; then
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
  
  [ "$DEBUG" = true ] && info VCS URL: "$VCS_URL" DOWNLOAD URL: "$DOWNLOAD_URL"
  
  End
  return
}

PLUGIN="$1"
DEBUG="${2:-false}"

info PLUGIN: "$PLUGIN" DEBUG: "$DEBUG"

jq -r --arg plugin  "$PLUGIN" '.plugins|map(select(.component == $plugin)) | .[]' "$RACINE"/pluglist.json > "$RACINE"/tmp.json
VCS_URL=$(jq -r '.source' "$RACINE"/tmp.json)
info VCS_URL: "$VCS_URL"

is_moodleversion_supported "$PLUGIN" '5.0'
