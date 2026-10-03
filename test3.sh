#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

function assert {
	# First parameter is the message in case the assertion is not verified
	local message="$1"

	# The remaining arguments make the command to execute
	shift

	# Run the command, $@ ensures arguments will remain in the same position.
	# "$@" is equivalent to "$1" "$2" "$3" etc.
	"$@"

	# Get the return code
	local rc=$?

	# If everything is okay, there's nothing left to do
	[ $rc -eq 0 ] && return 0

	# An error occured, retrieved the line and the name of the script where
	# it happend
	set $(caller)

	# Get the date and time at which the assertion occured
	date=$(date "+%Y-%m-%d %T%z")

	# Output an error message on the standard error
	# Format: date script [pid]: message (linenumber, return code)
	echo "$date $2 [$$]: $message (line=$1, rc=$rc)" >&2

	# Exit with the return code of the assertion test
	exit $rc
}




function add_plugins_from_list () {

  local project="$1" filename="$2" plugin error=0 
  Start "$*"
  [[ -f "$filename" ]] || { error "$filename" not exists; error=1; }
  
  while read -r line; do    
    plugin=$(echo "$line" | cut -f 1 -d " ")
    info Add: "$plugin"
    # check if already included
    if [[ -n $(jq -r --arg plugin  "$plugin" '.plugins|map(select(.name == $plugin))[].name' "$PROJECTS_PATH"/"$project"/"$project".json;) ]]; then
      jq  -r --arg plugin "$plugin" '.plugins[.plugins| length] |= . + { "name": $plugin }' "$PROJECTS_PATH"/"$project"/"$project".json > "$project".tmp && mv "$project".tmp "$PROJECTS_PATH"/"$project"/"$project".json
    fi
  done < "$filename"

  End
  return "$error"

}

function get_plugin_project_state () {

  Start "$*"
  # 1 PLUGIN
  PLUGIN="$1"
  MOODLE_VERSION="$2"
  
  local error=0 plugin_branch plugin_versionnumber plugin_version
  
  PLUGIN_STATE_TYPE=null
  PLUGIN_DESIRED_STATE=null
  [ "$DEBUG" == true ]&& info source project.json: "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json
  plugin_branch=$(jq --arg plugin "$PLUGIN" -r '.plugins[]|select(.name == $plugin) | .branch' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  [ "$DEBUG" == true ]&& info plugin_branch: "$plugin_branch"
  plugin_versionnumber=$(jq --arg plugin "$PLUGIN" -r '.plugins[]| select(.name==$plugin)|.versionnumber' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  [ "$DEBUG" == true ]&& info plugin_versionnumber: "$plugin_versionnumber"
  plugin_version=$(jq --arg plugin "$PLUGIN" -r '.plugins[]|select(.name==$plugin) | .version' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json)
  [ "$DEBUG" == true ]&& info  plugin_version: "$plugin_version"
  #[ "$DEBUG" == true ]&& info plugin_branch: "$plugin_branch" plugin_versionnumber: "$plugin_versionnumber" plugin_version: "$plugin_version"
  if [[ "$plugin_version" != null ]]; then
    PLUGIN_STATE_TYPE=version
    PLUGIN_DESIRED_STATE="$plugin_version"

  elif [[ "$plugin_branch" != null ]]; then
    PLUGIN_STATE_TYPE=branch
    PLUGIN_DESIRED_STATE="$plugin_branch"

  elif [[ "$plugin_versionnumber" != null ]]; then
    PLUGIN_STATE_TYPE=versionnumber
    PLUGIN_DESIRED_STATE="$plugin_versionnumber"
  else
    info no value for "$PLUGIN" in "$PROJECT".json
    error=1
  fi
  info PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" PLUGIN_DESIRED_STATE: "$PLUGIN_DESIRED_STATE"
  End
  return "$error"

}
# First find out if this was called from symlink,
# then find the real path of parent directory.
# This is needed because macOS does not have GNU realpath.
thisfile=$( readlink "${BASH_SOURCE[0]}" ) || thisfile="${BASH_SOURCE[0]}"
cd "$( cd "$( dirname "$thisfile" )/" && pwd -P )"

PROJECT="${1:-new52}"
PLUGIN="${2:-tool_datewatch}"
DEBUG=true

info PROJECT: "$PROJECT" debug: "$DEBUG" plugin: "$PLUGIN"

#get_project_conf "$PROJECT"

#clone_plugin "$PLUGIN"  
#is_official_plugin tool_automate

#is_moodleversion_supported tool_automate 5.2
config_check "$PROJECT"
exit

get_plugin_project_state "$PLUGIN" "$MOODLE_VERSION"

#get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION"

#release 
