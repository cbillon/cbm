#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-demo}"
PLUGIN="${2:-tool_redis}"
DEBUG="${3:-false}"

info PROJECT: "$PROJECT" debug: "$DEBUG"

get_project_conf "$PROJECT"

get_plugin_project_state "$PLUGIN" "$MOODLE_VERSION" || get_plugin_default_state "$PLUGIN" "$MOODLE_VERSION"

