#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="$1"
PLUGIN="$2"
DEBUG=true



function get_plugin_desired_state () {
  Start "$*"
  error=0
  PLUGIN="$1"
  
  get_plugin_params "$PROJECT" "$PLUGIN"
  
  # returned parameters
  # PLUGIN_BRANCH
  # PLUGIN_VERSION (tag)
  # PLUGIN_VERSIONNUMBER  yyyymmddxx
  

  PLUGIN_DESIRED_STATE=null
  if [[ "$PLUGIN_VERSION" != null ]]; then
    PLUGIN_DESIRED_STATE=version
    [ "$DEBUG" = true ] && info   PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE"  from PLUGIN_VERSION
  elif [[ "$PLUGIN_BRANCH" != null ]]; then
    PLUGIN_DESIRED_STATE=branch
    [ "$DEBUG" = true ] && info   PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE" from PLUGIN_BRANCH
  elif [[ "$PLUGIN_VERSIONNUMBER" != null ]]; then
    PLUGIN_DESIRED_STATE=versionnumber
    [ "$DEBUG" = true ] && info   PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE" from PLUGIN_VERSIONNUMBER
  else
    # no value configured search default value
    get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION"
  
  fi
   
  [ "$DEBUG" = true ] && info "  PLUGIN_DESIRED_STATE: $PLUGIN_DESIRED_STATE"
  cd "$DEPOT_MODULES"/"$PLUGIN" || exit
  
  return
  
  if [[ $(git rev-parse --verify "$PLUGIN_DESIRED_STATE") ]]; then
    git checkout "$PLUGIN_DESIRED_STATE" --quiet
    PLUGIN_DESIRED_STATE_SHA1=$(git rev-parse --short HEAD)
    [ "$DEBUG" = true ] && info "$PLUGIN" desired state sha1: "${PLUGIN_DESIRED_STATE_SHA1:0:7}"
  else
    error=1
    error git rev-parse --verify "$PLUGIN_DESIRED_STATE"
  fi
  
  get_plugin_dir "$PLUGIN"
  
  End
}

function get_plugin_default_state () {
  
  # 1 PLUGIN
  PLUGIN="$1"
  MOODLE_VERSION="$2"
  local error=0

  [ "$DEBUG" = true ] && info PLUGIN: "$PLUGIN"
  [ "$DEBUG" = true ] && info MOODLE_VERSION: "$MOODLE_VERSION"
  
  if is_moodleversion_supported "$PLUGIN" "$MOODLE_VERSION" ; then

    jq -r --arg plugin "$PLUGIN" '.plugins | map(select(.component == $plugin))' "$RACINE"/pluglist.json > tmp.json
    VCSTAG=$(jq -r --arg moodle_version "$MOODLE_VERSION" '[.[].versions[]| {version: .vcstag, moodle: .supportedmoodles[].release}]|.[]|select(.moodle == $moodle_version)|.version' "$RACINE"/tmp.json | sort -rn | head -n 1)
    if [[ -n "$VCSTAG" ]]; then
      success Tag: "$VCSTAG"
      PLUGIN_DESIRED_STATE=vcstag
      PLUGIN_STATE_VALUE="$VCSTAG"
    else
      warn "no tag..."
    fi
  else
    error "$PLUGIN" not supports Moodle version "$MOODLE_VERSION"
    error=1
  fi
  [ "$DEBUG" = true ] && info Plugin: "$PLUGIN" defaul state: "$PLUGIN_DESIRED_STATE" "$VCSTAG"

}

function dependency_mode () {
  local state
  state="$1"
  value="$2"
  case "$state" in
  "version")
    info "$state" : "$value";;
  "branch")
    info "$state" : "$value";;
  "versionnumber")
    info "$state" : "$value";;
  "vcstag")
    info "$state" : "$value";;
  *)
    error Unknown state "$state" 
  esac
} 

function get_plugin_params () {
  
  # decode parameters in conf file <project>.json
  # if new parameter add it
  # paramater not present value returned null

  Start "$*"
  #PROJECT="$1"
  #PLUGIN="$2"

  [ -d "$DEPOT_MODULES"/"$PLUGIN" ] || { error Plugin "$PLUGIN" not present; exit 1; }

  PLUGIN_BRANCH=$(jq --arg plugin "$PLUGIN" -r '.plugins[]|select(.name==$plugin).branch' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  PLUGIN_VERSIONNUMBER=$(jq --arg plugin "$PLUGIN" -r '.plugins[]| select(.name==$plugin).versionnumber' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  PLUGIN_VERSION=$(jq --arg plugin "$PLUGIN" -r '.plugins[]|select(.name==$plugin).version' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  
  End
}


info project: "$PROJECT" new plugin: "$PLUGIN" debug: "$DEBUG"

get_project_conf "$PROJECT"

get_plugins "$PROJECT"

i=0
for PLUGIN in "${PLUGINS[@]}"
do
    info "$i" "$PLUGIN"
    get_plugin_desired_state "$PLUGIN" "$MOODLE_VERSION"
    dependency_mode "$PLUGIN_DESIRED_STATE"  "$PLUGIN_STATE_VALUE" 
    info "$i" "$PLUGIN" moodle version: "$MOODLE_VERSION" etat demandé: "$PLUGIN_DESIRED_STATE"
    ((++i))
done
exit

# find tag 
    PLUGIN_TAG=$(jq -r --arg v "$MOODLE_VERSION" '[.versions[]| {version: .vcstag, moodle: .supportedmoodles[].release}]|.[]|select(.moodle == $v)|.version' tmp.json | sort -nr | head --lines 1) 
    [ "$DEBUG" == true ] && info plugin: "$PLUGIN" version: "$PLUGIN_MOODLE_VERSION" tag: "$PLUGIN_TAG"

