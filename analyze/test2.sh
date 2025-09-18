#!/bin/bash

moodle_array+=(MOODLE_VERSION MOODLE_MAJOR_VERSION MOODLE_BRANCH MOODLE_DESIRED_STATE MOODLE_DESIRED_STATE_SHA1)
plugin_array+=(PLUGIN_VERSION LOCALDEV PLUGIN_BRANCH COMPONENT_NAME TYPE DIR)

for value in "${moodle_array[@]}"; do
  echo $value
done

for value in "${plugin_array[@]}"; do
  echo $value
done