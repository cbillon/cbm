#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

function config_check () {

# 1 PROJECT

  Start "$*"
  [ "$DEBUG" = true ] && info Project: "$PROJECT"
  error=0
  # check validity .yml
  is_conf_file 
  # check MOODLE_VERSION
  get_project_conf
  # is up to date
  repo_need_upgrade "$MOODLE_SRC" "$MOODLE_BRANCH" && success "$MOODLE_BRANCH" already up to date || error "error $?" see previous message
  
  get_plugins
  for PLUGIN in $PLUGINS; do
    info "Check plugin: $PLUGIN"
    # check if plugin exists in cache
    if [[ -d "$DEPOT_MODULES"/"$PLUGIN" ]]; then
      cd "$DEPOT_MODULES"/"$PLUGIN"
      git remote | grep upstream >/dev/null || error "$PLUGIN" no upstream remote

      local plugin_branch plugin_version localdev
      plugin_branch=$(yq .plugins."$PLUGIN".branch  "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml)
      plugin_version=$(yq .plugins."$PLUGIN".version "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml)
      localdev=$(yq .plugins."$PLUGIN".localdev "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml)
      
      if [[ -n "$plugin_branch" ]]; then
        git checkout "$plugin_branch" --quiet 
      else
        search_plugin_state "$PLUGIN"
        if [[ -n "$PLUGIN_BRANCH" ]]; then
          pathenv=".plugins.$PLUGIN.branch" branche="$PLUGIN_BRANCH" yq -i 'eval(strenv(pathenv)) = strenv(branche)' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
          success  plugin: "$PLUGIN" branch "$PLUGIN_BRANCH" updated in config file
        fi
        
        if [[ -z "$plugin_version" ]] && [[ -n "$PLUGIN_VERSION" ]]  ; then
          pathenv=".plugins.$PLUGIN.version" version="$PLUGIN_VERSION" yq -i 'eval(strenv(pathenv)) = strenv(version)' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
          success  plugin: "$PLUGIN" branch "$PLUGIN_VERSION" updated in config file
        fi
      fi
    else
      [ "$DEBUG" = true ] && info "$PLUGIN" missing
      if find_plugin_source "$PLUGIN"; then
        error=1
        pathenv=".plugins.$PLUGIN.source" source="$SOURCE" yq -i 'eval(strenv(pathenv)) = strenv(source)' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
        clone_plugin "$PLUGIN" "$SOURCE"
        search_plugin_state "$PLUGIN"
        if [[ -n "$PLUGIN_BRANCH" ]]; then
          pathenv=".plugins.$PLUGIN.branch" branche="$PLUGIN_BRANCH" yq -i 'eval(strenv(pathenv)) = strenv(branche)' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
          error=0
          success  plugin: "$PLUGIN" branch "$PLUGIN_BRANCH" updated in config file
        fi
        
        if [[ -n "$PLUGIN_VERSION" ]]  ; then
          pathenv=".plugins.$PLUGIN.version" version="$PLUGIN_VERSION" yq -i 'eval(strenv(pathenv)) = strenv(version)' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
          error=0
          success  plugin: "$PLUGIN" branch "$PLUGIN_VERSION" updated in config file
        fi
      
      else
        error source plugin "$PLUGIN" not found
        error=1
      fi
    fi
  done

  [ "$error" -eq 0 ] && success Configuration file "$PROJECT" successful || error Please correct configuration file and retry

  End
  return
}

PROJECT="$1"
DEBUG=true
PLUGIN="$2" 
get_moodle_desired_state "$PROJECT"

search_plugin_state "$PLUGIN"
info "$PLUGIN_BRANCH"
info "$PLUGIN_VERSION"
[[ -n "$PLUGIN_BRANCH" ]] && info "$PLUGIN_BRANCH" OK || error "$PLUGIN_BRANCH" KO
[[ -n "$PLUGIN_VERSION" ]] && info "$PLUGIN_VERSION" OK || error "$PLUGIN_VERSION" KO

cd "$DEPOT_MODULES"/"$PLUGIN"

var=(git branch --contains $(git rev-parse --short HEAD)) | rev | cut -d' ' -f1 | rev

info var: "$var"
info "That's All!"