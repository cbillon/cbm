#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-demo}"
DEBUG=false
echo project: "$PROJECT"