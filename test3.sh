#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="$1"
DEBUG=true
PLUGIN="$2" 
install_official_plugin "$PROJECT" "$PLUGIN"
info "That's All!"