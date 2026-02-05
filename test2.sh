#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

LC_ALL=fr_FR.UTF-8

function func1 () {
  echo func 1 CB
}

function func2 () {
  echo func 2 CB
}

function func3 () {
  echo func 3 CB
}

function menu () {

sel=$(zenity --list --width=600 --height=450 --text="Menu CBM" \
	--ok-label="Sélectionner" \
	--cancel-label="Quitter" \
	--hide-column 2 --print-column 2 --column "Plugin" --column fonction \
  "Import d'un plugin (cache)" add_plugin_cache \
  "Liste des plugins (cache)" list_plugins_cache \
  "Ajout d'un plugin au projet" add_plugin_project \
  "Retirer un plugin du projet" rm_plugin \
  "Verification de la configuration du projet" config_check \
  "Mise a jour de Moodle" update_moodle  \
  "Mise a jour du cache des plugins" update_plugins_repo \
  "Mise a jour de la base de code" update_codebase \
  "Livraison d'une nouvelle version de la base de code" release \
  "Exit" cbm_exit
)
  
}
 
  menu
  info retour: "$?" "$sel"
  "$sel"
  exit


#PROJECT=$(menu --inputbox "What is your project?" 8 39 "$PROJECT_CURRENT" --title "Code Base Manager")

PROJECT=$(zenity --entry --text="What is your project?" --title "Code Base Manager" --width=300)
echo retour: "$?"
if [ -n "$PROJECT" ]; then
  info OK "$PROJECT"
else
  error ko!
fi

exit

#menu --title "Boite de dialogue Oui / Non" --yesno "Create new project $PROJECT ?" 10 60


REP=$(zenity --question --text "Are you sure you want to create new project $PROJECT?" --no-wrap --ok-label "Yes" --cancel-label "No")

echo rep: "$REP"

info "That's All!"