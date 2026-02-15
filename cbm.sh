#!/bin/bash

#exec 1> >(logger -s -t $(basename $0)) 2>&1

function cbm_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
  #Lancement de Code Base Manager
  cat > /dev/stdout <<- END
  Lancement depuis le répertoire d'installation
  	${0} [-d] [-h] [-l]

		OPTIONAL ARGS:
    -d : set mode debug (default false)
	    -h : show help
    -l : logging mode terminal_or_file (default) terminal_and_file only_file
   
		EXAMPLES
     cd cbm
		 ./cbm.sh -d


  ## La documentation

  Elle se trouve dans le repertoire docs

  Elle est organisée de la façon suivante:
  - tutorials : infos pour démarrer : pre requis , installation du script, tutoriel
  - how-to-guide : desciption des différentes commandes
  - référence : spécifications du produit
  - discussions: documents relatifs au sujet : version moodle,semantic versionning,  moodle gestion des branches ...

  ## La base de code
  La base de code générée pour le projet se trouve dans le dépot local Moodle avec une branche correspondant au nom du projet

  Consultez le fichier README.md qui se trouve dans le répertoire d installation.
END

}

DEBUG=false
while getopts "h?dl:" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		cbm_help
		exit 0
		;;
	d) DEBUG=true ;;
  l) logging_mode="$OPTARG" ;;
	esac
done

if [ ! -f includes/env.cnf ]; then
  cp env.cnf.default includes/env.cnf
  nano includes/env.cnf
  [ ! -f includes/env.cnf ] && exit
  info Create includes/env.cnf
fi

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

setup_logging

info DEBUG: "$DEBUG"
info log file: "$logfile" logfile policy: "$logfile_policy" logging mode: "$logging_mode"

# Le script
#CURRENT_DIR=$(dirname "${0}")
#SCRIPT_NAME=$(basename "${0}")
HOSTNAME=$(hostname)
DATE_DU_JOUR=$(date)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

[ $EUID -eq 0 ] && error "This script must run as normal user" && exit 1

# Verify pre requis

git --version 1>/dev/null || { error git not installed see README.md; exit; }
jq --version 1>/dev/null || { error jq not installed see README.md; exit; }

#[ -d "$PROJECTS_PATH" ] || create_env
# restore last project

PROJECT=$(yad --entry --text "What is your project? $PROJECT_CURRENT" --entry-text "$PROJECT_CURRENT" --title "Code Base Manager")
if [[ "$?" -eq 0 && -n "$PROJECT" ]]; then
  if [ -d "$PROJECTS_PATH"/"$PROJECT" ]; then
    # save current project
    sed -i "s/^PROJECT_CURRENT=.*/PROJECT_CURRENT=$PROJECT/" "$RACINE/includes/env.cnf"
    info "Project: $PROJECT"
  else
    # menu --title "Boite de dialogue Oui / Non" --yesno "Create new project $PROJECT ?" 10 60
    

    if yad --image="dialog-question" \
    --title "Alert" \
    --text "Create a new Project?" \
    --button="gtk-no:1" \
    --button="gtk-yes:0" ; then
      error=1
      while [ "$error" -ne 0 ]; do
        #parm=$(menu --inputbox "What is your Moodle version?" 8 39 --title "Conf $PROJECT" "$MOODLE_VERSION_DEFAULT")
        #parm=$(zenity --entry --text "What is your Moodle version?" --title "Code Base Manger $PROJECT" --entry-text "$MOODLE_VERSION_DEFAULT")
        parm=$(yad --form \
        --window-icon=gtk-preferences \
        --align=right \
        --width=150 \
        --mouse \
        --title="CodeBase Manager configurator" \
        --field="Admin:" "admin" \
        --field="Admin em mail" "admin@gmail.com" \
        --field="Branch project:" "$PROJECT" \
        --field="Moodle Version:CBE" 4.5\!5.0\!5.1\!5.2 \
        --field="Description:TXT" \
        --button="About!gtk-about":"bash -c about_dlg" \
        --button="Cancel!gtk-cancel":1 \
        --button="Yes!gtk-yes":0)

        [[ "$?" -eq 0 && -n "$parm" ]] || exit 1
        if is_moodle_version_valid "$parm"; then
          error=0
        else
          error Invalid Moodle version "$parm"
        fi
      done

      info Call create project "$PROJECT" "$parm"
      create_project "$PROJECT" "$parm"
      info Project "$PROJECT" created

    else
       error "Cancel."
       exit 1
    fi
  fi
else
   echo "Select canceled."
   exit 1
fi

# Verify date pluglist.json reload if needed
get_pluglist "$DIFF_DAYS"

get_project_conf "$PROJECT"

while true ; do

  func=$(yad --list --no-headers --width=450 --height=450 --text="Menu CBM"  --title="Code Base Manager" \
	  --hide-column 2 --print-column 2 --column "Plugin" --column fonction --separator=" " \
    "Plugin import (cache)" add_plugin_cache \
    "Plugins list (cache)" list_plugins_cache \
    "Add plugin to project" add_plugin_project \
    "Remove plugin from project" rm_plugin \
    "Check project configuration" config_check \
    "Update core Moodle" update_moodle  \
    "Update plugins in cache" update_plugins_repo \
    "Sync codebase" update_codebase \
    "Release a new codebase version" release \
    "Exit" exit
  )
  
  if [[ "$?" -eq 0 && -n "$func" ]]; then
    [ "$DEBUG" = true ] && info function: "$func"
    $func
  else
    error "Code Base Manager exit"
    break
  fi   
  
done

info Bye Bye