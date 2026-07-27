#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

# First find out if this was called from symlink,
# then find the real path of parent directory.
# This is needed because macOS does not have GNU realpath.
thisfile=$( readlink "${BASH_SOURCE[0]}" ) || thisfile="${BASH_SOURCE[0]}"
cd "$( cd "$( dirname "$thisfile" )/" && pwd -P )"

PROJECT="${1:-new52}"
PLUGIN="${2:-tool_redis}"
DEBUG=true

info PROJECT: "$PROJECT" debug: "$DEBUG" plugin: "$PLUGIN"

get_project_conf "$PROJECT"
