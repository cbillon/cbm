#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-demo}"
PLUGIN="$2"
DEBUG="${3:-false}"

info PROJECT: "$PROJECT" PLUGIN: "$PLUGIN" debug: "$DEBUG"

get_project_conf "$PROJECT"
is_official_plugin "$PLUGIN"
get_plugin_desired_state "$PLUGIN" "$MOODLE_VERSION"

info PLUGIN: "$PLUGIN" "$PLUGIN_STATE_TYPE" : "$PLUGIN_DESIRED_STATE"
install_plugin_project "$PLUGIN" "$PLUGIN_STATE_TYPE" "$PLUGIN_DESIRED_STATE"