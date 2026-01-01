#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="$1"
DEBUG="${2:-false}"

function get_plugin_desired_state () {
 
  Start "$*"
  local error=0
  PLUGIN="$1"
  
  # returned parameters from <project>.json
 
  # VERSION (tag)
  # BRANCH
  # VERSIONNUMBER  yyyymmddxx
  
  get_plugin_params "$PLUGIN"

  PLUGIN_STATE_TYPE=null
  PLUGIN_DESIRED_STATE=null
  if [[ "$PLUGIN_VERSION" != null ]]; then
    PLUGIN_STATE_TYPE=version
    PLUGIN_DESIRED_STATE="$PLUGIN_VERSION"
    [ "$DEBUG" = true ] && info   PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE"  from PLUGIN_VERSION
  elif [[ "$PLUGIN_BRANCH" != null ]]; then
    PLUGIN_STATE_TYPE=branch
    PLUGIN_DESIRED_STATE="$PLUGIN_BRANCH"
    [ "$DEBUG" = true ] && info   PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" from PLUGIN_BRANCH
  elif [[ "$PLUGIN_VERSIONNUMBER" != null ]]; then
    PLUGIN_STATE_TYPE=versionnumber
    PLUGIN_DESIRED_STATE="$PLUGIN_VERSIONNUMBER"
    [ "$DEBUG" = true ] && info   PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" from PLUGIN_VERSIONNUMBER
  else
    # no value configured search default value
    get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION"  
  fi
  
  [ "$DEBUG" = true ] && info "  PLUGIN_STATE_TYPE: $PLUGIN_STATE_TYPE" PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE"  
    
  End
  return "$error"

}

function get_plugin_default_state () {
  
  Start "$*"
  # 1 PLUGIN
  PLUGIN="$1"
  MOODLE_VERSION="$2"
  local error=0

  [ "$DEBUG" = true ] && info PLUGIN: "$PLUGIN"
  [ "$DEBUG" = true ] && info MOODLE_VERSION: "$MOODLE_VERSION"
  
  if is_moodleversion_supported "$PLUGIN" "$MOODLE_VERSION" ; then
    jq -r --arg plugin "$PLUGIN" '.plugins | map(select(.component == $plugin))' "$RACINE"/pluglist.json > "$RACINE"/tmp.json
    VCSTAG=$(jq -r --arg moodle_version "$MOODLE_VERSION" '[.[].versions[]| {version: .vcstag, moodle: .supportedmoodles[].release}]|.[]|select(.moodle == $moodle_version)|.version' "$RACINE"/tmp.json | sort -rn | head -n 1)
    if [[ -n "$VCSTAG" ]]; then
      success Tag: "$VCSTAG"
      PLUGIN_STATE_TYPE=vcstag
      PLUGIN_DESIRED_STATE="$VCSTAG"
    else
      warn "no tag..."
    fi
  else
    error "$PLUGIN" not supports Moodle version "$MOODLE_VERSION"
  #  error=1
  fi
  [ "$DEBUG" = true ] && info Plugin: "$PLUGIN" default state: "$PLUGIN_STATE_TYPE" desired state: "$PLUGIN_DESIRED_STATE" 
  
  End
  return "$error"

}

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

    # plugin already installed
    cd "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME" || exit
    STATE_TYPE=null
    STATE=null
    [[ $(grep .gitrepo -e 'PLUGIN_STATE_TYPE=') =~ ^.*PLUGIN_STATE_TYPE=(.*)$ ]] && STATE_TYPE="${BASH_REMATCH[1]}"
    [[ $(grep .gitrepo -e 'PLUGIN_DESIRED_STATE=') =~ ^.*PLUGIN_DESIRED_STATE=(.*)$ ]] && STATE="${BASH_REMATCH[1]}"
  
    [ "$DEBUG" = true ] && info state type in plugin: "$STATE_TYPE" state: "$STATE"

    if [ "$PLUGIN_STATE_TYPE" == "$STATE_TYPE" ] && [ "$PLUGIN_DESIRED_STATE" == "$STATE" ]; then
      success "$PLUGIN" type "$STATE_TYPE" state "$PLUGIN_DESIRED_STATE" OK
    else
      install_plugin_project "$PLUGIN" "$PLUGIN_STATE_TYPE" "$PLUGIN_DESIRED_STATE"
    fi
  else
    info "$PLUGIN" not installed
    get_plugin_desired_state "$PLUGIN"
    install_plugin_project "$PLUGIN" "$PLUGIN_STATE_TYPE" "$PLUGIN_DESIRED_STATE"
  fi

  End
}

function install_plugin_project ()  {
  # install plugin (add or update)
  Start "$*"
  local error=0 
  PLUGIN="$1"
  PLUGIN_STATE_TYPE="$2"
  PLUGIN_DESIRED_STATE="$3"

  [ "$DEBUG" == true ] && info PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE"
  
  case "$PLUGIN_STATE_TYPE" in
  "version")
    info PLUGIN_STATE_TYPE "$PLUGIN_STATE_TYPE";;
  "branch")
    info PLUGIN_STATE_TYPE "$PLUGIN_STATE_TYPE";;
  "versionnumber")
    info PLUGIN_STATE_TYPE "$PLUGIN_STATE_TYPE";;
  "vcstag")
    info PLUGIN_STATE_TYPE "$PLUGIN_STATE_TYPE"
    install_plugin_vcstag "$PLUGIN" "nothing to say" "$PLUGIN_STATE_TYPE" "$PLUGIN_DESIRED_STATE";;
  *)
    error Unknown PLUGIN_STATE_TYPE "$PLUGIN_STATE_TYPE";;
  esac
  
  End
  return "$error"
}

function install_plugin_vcstag () {
  
  Start "$*"
  local error=0 
  PLUGIN="$1"
  MSG="$2"
  PLUGIN_STATE_TYPE="$3"
  PLUGIN_DESIRED_STATE="$4"
  
  [ "$DEBUG" == true ] && info "$1" "$2" "$3" "$4"

  [ -d "$DEPOT_MODULES"/"$PLUGIN" ] || { error "$PLUGIN" not in cache; exit; }
  cd "$DEPOT_MODULES"/"$PLUGIN" || exit
  
  cd "$MOODLE_SRC" || exit
  git checkout "$PROJECT_BRANCH" --quiet
  
  get_plugin_dir "$PLUGIN"

  if [ ! -d "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME" ]; then
    mkdir -p "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME"
  fi
  rsync -a --delete --exclude '.git' "$DEPOT_MODULES"/"$PLUGIN/" "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME/"
 
  echo "    PLUGIN_STATE_TYPE=$PLUGIN_STATE_TYPE" > "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME"/.gitrepo
  echo "    PLUGIN_DESIRED_STATE=$PLUGIN_DESIRED_STATE" >> "$MOODLE_SRC"/"$DIR"/"$COMPONENT_NAME"/.gitrepo
  git add .
  git commit -m "$MSG" --quiet
  
  End
  return "$error"
}

info project: "$PROJECT" debug: "$DEBUG"

get_project_conf "$PROJECT"

get_plugins "$PROJECT"

for PLUGIN in "${PLUGINS[@]}"
do
    info plugin: "$PLUGIN"
    codebase_need_update "$PLUGIN"
done
exit