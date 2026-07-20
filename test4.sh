#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

info That s All !

PROJECT="${1:-new52}"
DEBUG=true
PLUGIN="${2:-tool_datewatch}"

info PROJECT: "$PROJECT" debug: "$DEBUG" plugin: "$PLUGIN"

get_project_conf "$PROJECT"
#MOODLE_VERSION="5.1"
#get_plugin_dir  "$PLUGIN"

get_plugin_project_state "$PLUGIN" "$MOODLE_VERSION" 

info PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" PLUGIN_DESIRED_STATE  "$PLUGIN_DESIRED_STATE"

get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION" 

info PLUGIN_STATE_TYPE: "$PLUGIN_STATE_TYPE" PLUGIN_DESIRED_STATE  "$PLUGIN_DESIRED_STATE"
