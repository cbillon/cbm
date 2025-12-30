#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

state="$1"
DEBUG=true



info state: "$state" debug: "$DEBUG"

case "$state" in
  "version")
    info "$state" ;;
  "branch")
    info "$state" ;;
  "versionnumber")
    info "$state" ;;
  "vcstag")
    info "$state" ;;
  *)
    error Unknown state "$state" 
esac