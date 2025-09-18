#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

function show_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
	cat > /dev/stdout <<- END
		${0} -p <project> -v <moodle_version> [-m <plugin install>] [-s <steps>]
		  [-d ] [-h]

		REQUIRED ARGS:
		
		OPTIONAL ARGS:
    -d - debug mod
		-r - reload json file
		-h - show help

		EXAMPLES
    - ./test.sh -r
END
}

# while loop, and getopts
DEBUG=false
RELOAD=false
while getopts "h?dp:r" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		show_help
		# exit code
		exit 0
		;;
	d) DEBUG=true ;;
  p) PLUGIN=${OPTARG} ;; 
  r) RELOAD=true ;;
  esac
done

info debug: "$DEBUG" reload: "$RELOAD"

function reload_file () {
  info "$*"
  error=0
  if [ -f "$RACINE"/pluglist.json ]; then
    rm pluglist.jsonnow
  fi
  wget download.moodle.org/api/1.3/pluglist.php -O "$RACINE"/pluglist.json 
  return $error
  info End 
}

function find_plugin_source () {
  Start "$*"
  local error
  error=0
  [ "$DEBUG" = true ] && info Plugin: "$PLUGIN"
  jq -r --arg plugin  "$PLUGIN" '.plugins|map(select(.component == $plugin)) | .[]' "$RACINE"/pluglist.json > tmp.json
  
  MOODLE='4.9'
  var=$(jq -r --arg moodle $MOODLE '.versions[] | .supportedmoodles [] .release | select(contains ($moodle))|@sh' "$RACINE"/tmp.json)
  info $var
  if [ -z $var ]; then
    error "$PLUGIN" ne supporte pas la version "$MOODLE"
  else
    success "$PLUGIN" supporte la version "$MOODLE"
  fi



  [ "$DEBUG" = true ] && info id: "$var"
      
  
  # COMPONENT=$(jq -r '.component' "$RACINE"/tmp.json)  # <type>_<plugin name>
  # NAME=$(jq -r '.name' "$RACINE"/tmp.json)  # description
  # SOURCE=$(jq -r '.source' "$RACINE"/tmp.json)
  # VERSIONS=$(jq -r '.[] | . .versions' "$RACINE"/tmp.json)
  # info versions: "$VERSIONS"
  # [ "$DEBUG" = true ] && info PLUGIN: "$COMPONENT" "$NAME" "$SOURCE"
 
  # pour o la version du plugin a partir de la version Moodle
  # supprimer  |  select(.vcstag != null)  si on veut 
  # [.versions[] | select(.vcstag != null) | {id: .id,version: .version,tag: .vcstag, moodle: .supportedmoodles[]} | select (.moodle.release == "2.0")] | last

  End
  return "$error"
}

[[ "$RELOAD" = true  ]] && reload_file

find_plugin_source 
[[ "$DEBUG" = true ]] && wait_keyboard

info "That's All!"