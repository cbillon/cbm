#!/bin/bash

#exec 1> >(logger -s -t $(basename $0)) 2>&1

function cbm_help() {
	# Here doc, note _not_ in quotes, as we want vars to be substituted in.
	# Note that the here doc uses <<- to allow tabbing (must use tabs)
	# Note argument zero used here
  #Lancement de Code Base Manager
  cat > /dev/stdout <<- END
  Lancement depuis le répertoire d'installation
  	${0} [-d] [-h]

		OPTIONAL ARGS:
  -d : set mode debug
	  -h : show help

		EXAMPLES
     cd cbm
		 ./cbm -d


  ## La documentation

  Elle se trouve dans le repertoire docs

  Elle est organisée de la façon suivante:
  - tutorials : infos pour démarrer : pre requis , installation du script, tutoriel
  - how-to-guide : desciption des différentes commandes
  - référence : spécifications du produit
  - discussions: documents relatifs au sujet : version moodle,semantic versionning,  moodle gestion des branches ...

  ## La base de code
  La base de code générée pour le projet se trouve dans le dépot "$MOODLE_SRC" branche $PROJECT_BRANCH

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
		# exit code
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
source includes/menu."$LANG"
source includes/bash_strict.sh

info DEBUG: "$DEBUG"

setup_logging
info log file: "$logfile" logfile policy: "$logfile_policy" logging mode: "$logging_mode"

# Le script
#CURRENT_DIR=$(dirname "${0}")
#SCRIPT_NAME=$(basename "${0}")
HOSTNAME=$(hostname)
DATE_DU_JOUR=$(date)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

[ $EUID -eq 0 ] && echo error "This script must run as normal user" && exit 1

# Verify pre requis

git --version 1>/dev/null || { error git not installed see README.md; exit; }
jq --version 1>/dev/null || { error jq not installed see README.md; exit; }

#[ -d "$PROJECTS_PATH" ] || create_env
# restore last project

PROJECT=$(menu --inputbox "What is your project?" 8 39 "$PROJECT_CURRENT" --title "Code Base Manager")

if [[ "$?" -eq 0 ]]; then
  if [ -d "$PROJECTS_PATH"/"$PROJECT" ]; then
    # save current project
    sed -i "s/^PROJECT_CURRENT=.*/PROJECT_CURRENT=$PROJECT/" "$RACINE/includes/env.cnf"
    info "Project: $PROJECT"
  else
    menu --title "Boite de dialogue Oui / Non" --yesno "Create new project $PROJECT ?" 10 60
    if [[ "$?" -eq 0 ]]; then
      error=1
      while [ "$error" -ne 0 ]; do
        parm=$(menu --inputbox "What is your Moodle version?" 8 39 --title "Conf $PROJECT" "$MOODLE_VERSION_DEFAULT")
        [[ "$?" -eq 0 ]] || exit 1
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
get_pluglist

get_project_conf "$PROJECT"

sortie=0

while [ $sortie = 0 ];
do
  OPTION=$(menu --title "Code Base Manager" --menu "Project : ${PROJECT}" 20 60 12 \
  "0"  "${menu[0]}" \
  "1"  "${menu[1]}" \
  "2"  "${menu[2]}" \
  "3"  "${menu[3]}" \
  "4"  "${menu[4]}" \
  "5"  "${menu[5]}" \
  "6"  "${menu[6]}" \
  "7"  "${menu[7]}" \
  "8"  "${menu[8]}" \
  "9"  "${menu[9]}" ) || true


  if [ "$?" -eq 0 ]; then
    if   [ "$OPTION" = 0 ]; then add_plugin_cache
    elif [ "$OPTION" = 1 ]; then list_plugins_cache
    elif [ "$OPTION" = 2 ]; then add_plugin_project
    elif [ "$OPTION" = 3 ]; then rm_plugin
    elif [ "$OPTION" = 4 ]; then config_check
    elif [ "$OPTION" = 5 ]; then update_moodle
    elif [ "$OPTION" = 6 ]; then update_plugins_repo
    elif [ "$OPTION" = 7 ]; then update_codebase
    elif [ "$OPTION" = 8 ]; then release
    elif [ "$OPTION" = 9 ]; then sortie=1
    else
     echo "Vous avez annulé"
     sortie=1
    fi
  else
    #"Vous avez annulé... :-("
    #sortie=1
    exit
  fi

  if [ "$DEBUG" = true ];
  then
    wait_keyboard
  fi
done

info Bye Bye