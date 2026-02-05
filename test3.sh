#!/bin/bash

source includes/env.cnf
source includes/functions.cfg
source includes/bash_strict.sh

PROJECT="${1:-demo}"
DEBUG=false
echo project: "$PROJECT"
# sel=$(zenity --list --width=600 --height=450 --text="Menu CBM" \
# 	--ok-label="Sélectionner" \
# 	--cancel-label="Quitter" \
# 	--hide-column 2 --print-column 2 --column "Plugin" --column fonction \
#   "Import d'un plugin (cache)" add_plugin_cache \
#   "Liste des plugins (cache)" list_plugins_cache \
#   "Ajout d'un plugin au projet" add_plugin_project \
#   "Retirer un plugin du projet" rm_plugin \
#   "Verification de la configuration du projet" config_check \
#   "Mise a jour de Moodle" update_moodle  \
#   "Mise a jour du cache des plugins" update_plugins_repo \
#   "Mise a jour de la base de code" update_codebase \
#   "Livraison d'une nouvelle version de la base de code" release \
#   "Exit" cbm_exit
# )
list=''
# Retrieve plugins already in configuration file
  cd "$PLUGINS_REPO" || exit  
  for p in $(ls -l "$PLUGINS_REPO" | awk '{print $9}'); do
    # save plugins not in project configuration file
    if [[ -z $(jq -r '.plugins[].name' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json | grep "$p" ) ]]; then
      list+="FALSE $p "
    fi
  done
  echo $list
  
  #PLUGIN=$(menu --title "Plugins cache" --checklist "Plugin's List" 25 78 16 $list) && ret="$?" || ret="$?"
  PLUGIN=$(zenity --list --radiolist --text "Add plugin to project $PROJECT" --title "Code Base Manger Add plugin to project" \
    --column Use --column Plugin $list)
  error="$?"

exit


get_project_conf "$PROJECT"

list=$(jq -r '.plugins[].name | "FALSE "+.' "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".json | tr  '\n' ' ')
echo "$list"
PLUGIN=$(zenity --list --radiolist --text "Add plugin to project $PROJECT" --title "Code Base Manger Add plugin to project" \
     --column Use --column Plugin $list)

[[ "$?" -eq 0 && -n "$PLUGIN" ]] && success plugin: "$PLUGIN" || error kO!




# get_plugins "$PROJECT"
# exit
# compute windows height 
# h=$(($(find "$PLUGINS_REPO" -maxdepth 1 -type d -print| wc -l)*28))
# echo nb plugins "$h" 
# [ "$h" -gt 672 ]&& h=672
# echo nb plugins "$h" 
# zenity --list --height="$h" --column=Plugin $(ls -1 "$PLUGINS_REPO")

# sel=$(zenity --list --width=600 --height=450 --text="Menu CBM" \	
#   --ok-label="Sélectionner" \
# 	--cancel-label="Quitter" \
# 	--column="Plugin" \
#   $(ls -1 "$PLUGINS_REPO"))

# zenity --list --height="300" --column=Plugin $(ls -1 "$PLUGINS_REPO")
liste="TRUE Apples TRUE Oranges FALSE Pears FALSE Toothpaste"
# liste=$(ls -1 "$PLUGINS_REPO")
# zenity --list --column "Buy" --column "Item" TRUE Apples TRUE Oranges FALSE Pears FALSE Toothpaste
# exit
# cd "$PLUGINS_REPO" || exit
#   list=''
#   for d in $(ls -l "$PLUGINS_REPO" | awk '{print $9}'); do
#     # save plugins not in project configuration file
#     if [[ -z $(jq -r '.plugins[].name' /home/cb/cbm/projects/"$PROJECT"/"$PROJECT".json | grep "$d" ) ]]; then
#       #list="$list $d $i OFF"
#       list+="$d "
#     fi
#   done
#   echo -e $list

#   #PLUGIN=$(menu --title "Plugins cache" --checklist "Plugin's List" 25 78 16 $list) && ret="$?" || ret="$?"
#   PLUGIN=$(zenity --list --radiolist --text "Add plugin to project $PROJECT" --title "Code Base Manger Add plugin to project" \
#     --column Use --column $list)
#   if [[ "$?" -eq 0 && -n "$PLUGIN" ]]; then
#     info choice: "$?" "$PLUGIN"
#   else
#     error Cancel
#   fi