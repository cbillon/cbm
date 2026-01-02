#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PLUGIN="$1"
DEBUG="${2:-false}"

jq -r --arg plugin  "$PLUGIN" '.plugins|map(select(.component == $plugin)) | .[]' "$RACINE"/pluglist.json > "$RACINE"/tmp.json
VCS_URL=$(jq -r '.source' "$RACINE"/tmp.json)
info VCS_URL: "$VCS_URL"