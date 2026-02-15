#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

info PROJECT: "$PROJECT" debug: "$DEBUG"

get_project_conf "$PROJECT"

