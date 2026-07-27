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

get_plugin_branch "$PLUGIN"

info plugin branch: "$PLUGIN_BRANCH"
exit
if [[ $(git branch --contains "$PLUGIN_DESIRED_STATE") =~ ^[^ \*].*$ ]]; then
    [ "$DEBUG" = true ] && info branch found: "${BASH_REMATCH[1]}"
    plugin_branch="${BASH_REMATCH[1]}"

    info plugin branch: "$plugin_branch"
fi
exit
jq  -r --arg plugin "$PLUGIN" \
'.plugins[.plugins| length] |= . + { "name": $plugin }' \
 "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json > \
 "$PROJECT".tmp && mv "$PROJECT".tmp "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json

jq  -r --arg plugin "$PLUGIN" --arg branch "$plugin_branch" --arg version "$PLUGIN_DESIRED_STATE" \
    '.plugins[.plugins| length] |= . + { "name": $plugin, "branch": $branch, "version": $version }' \
    "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json > \
    "$PROJECT".tmp && mv "$PROJECT".tmp "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json