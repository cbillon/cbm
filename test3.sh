#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

function is_moodleversion_supported () {  
  local error version
  error=0
  PLUGIN="$1"
  MOODLE_VERSION="$2"

  if (is_official_plugin "$PLUGIN"); then
  # version=$(jq -r '[.versions[]| {(.version) : (.supportedmoodles[].release)}]' tmp.json | grep -w  $MOODLE_VERSION | sort -nr | grep -E -o  "([0-9]{10})" | sed -n '1 p')
    version=$(jq -r '[.versions[]| {(.version) : (.supportedmoodles[].release)}]' tmp.json | grep -w  $MOODLE_VERSION || true)
    [[ -n "$version" ]] && success "$PLUGIN" "$MOODLE_VERSION" supported || { warn "$PLUGIN" "$MOODLE_VERSION" not supported; error=0; }
  else
    error "$PLUGIN" is not an official plugin
    error=1 
  fi

  return "$error"
}

DEBUG=true
PLUGIN="$1" 
MOODLE_VERSION="$2"

is_moodleversion_supported "$PLUGIN" "$MOODLE_VERSION"

info "That's All!"