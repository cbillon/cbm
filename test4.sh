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

[[ "$DEBUG" = true ]] && info debug "$PROJECT" "$MOODLE_VERSION"

get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION"