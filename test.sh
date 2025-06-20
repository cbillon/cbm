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
		-p - Project (required)
		-v - Moodle version (required)
    

		OPTIONAL ARGS:
		-m - plugin to install
    -s - steps 0-8 for all steps 0,1,2,3,4,5,6,7,8	
    -d - debug default : false	
		-h - show help

		EXAMPLES
    - cd test
		- ./test.sh -p test -v 5.0+ -m mod_attendance -s 0,1,2,3,4,5,6,7,8
END
}

function raz () {
  
  # supress project
  [[ -d "$RACINE"/projects/"$1" ]] && sudo rm -r "$RACINE"/projects/"$1" || echo no existing project "$1" to remove
  create_env
  # suppress project's branch
  if [[ -d "$MOODLE_SRC" ]]; then
    cd "$MOODLE_SRC"
    git branch -D "$1" || echo no existing branch "$1" to delete  
  fi
  # suppress plugin
  [ -d "$DEPOT_MODULES"/"$2" ] && sudo rm -r "$DEPOT_MODULES"/"$2" || echo no existing module "$2" to delete 
  success "CBM reset"
}

# while loop, and getopts
DEBUG=false
while getopts "h?dp:m:s:v:" opt
do
	# case statement
	case "${opt}" in
	h|\?)
		show_help
		# exit code
		exit 0
		;;
	d) DEBUG=true ;;
	m) pl=${OPTARG} ;;
  p) PROJECT=${OPTARG} ;;
	s) st=${OPTARG} ;;
  v) vn=${OPTARG} ;;
	esac
done

info projet: "$PROJECT" version: "$vn" plugin: "$pl" steps: "$st" debug: "$DEBUG"

step=0
if [[ "$st" =~ "$step" ]]; then
  info Start step: "$step"
  info Remise à zero environnement du projet
  raz "$PROJECT" "$pl" 
  [[ "$DEBUG" = true ]] && wait_keyboard
  info End step: "$step" 
fi

# step 1 create project
step=1
if [[ "$st" =~ "$step" ]]; then
  info Start step: "$step"
  create_project "$PROJECT" "$vn"
  # test results
  is_project  && success dir "$PROJECT" created # check existance dir projects/PROJECT
  is_conf_file && success syntax config file ok # check syntax config file $PROJECT.yml
  is_version_valid "$MOODLE_VERSION" && success "$MOODLE_VERSION" valid  
  get_moodle_desired_state
  info PROJECT: "$PROJECT" PROJECT_BRANCH: "$PROJECT_BRANCH" MOODLE_BRANCH: "$MOODLE_BRANCH"
  [[ "$DEBUG" = true ]] && wait_keyboard
  info End step: "$step"
fi 

# step 2
step=2
if [[ "$st" =~ "$step" ]]; then
  info Start step: "$step"
  info Ajout du plugin "$pl" dans le fichier de configuration
  get_project_conf
  is_project_branch
  get_moodle_desired_state
  config_check "$PROJECT"
  echo "  $pl:" >> "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
  nano "$PROJECTS_PATH"/"$PROJECT"/"$PROJECT".yml
  config_check "$PROJECT"
  [[ "$DEBUG" = true ]] && wait_keyboard
  info End step: "$step"
fi

#step 3
step=3
if [[ "$st" =~ "$step" ]]; then 
  info Start step: "$step"
  info update Moodle repository and update project
  update_moodle "$PROJECT"
  [[ "$DEBUG" = true ]] && wait_keyboard || info End step "$step"
fi

#step 4
step=4
if [[ "$st" =~ "$step" ]]; then
  info Start step: "$step" 
  info Update project "$PROJECT"
  update_project "$PROJECT"
  [[ "$DEBUG" = true ]] && wait_keyboard || info End step "$step"
  info End step: "$step"
fi

#step 5
step=5
if [[ "$st" =~ "$step" ]]; then 
  info Start step: "$step"
  info Update plugins repo
  update_plugins_repo "$PROJECT"
  [[ "$DEBUG" = true ]] && wait_keyboard || info End step "$step"
  info End step: "$step"
fi

#step 6
step=6
if [[ "$st" =~ "$step" ]]; then 
  info Start step: "$step"
  info Update codebase
  update_codebase "$PROJECT"
  # check result
  info check is plugin installed  
  is_plugin_installed "$pl" && success Plugin "$pl" successfully checked
  [[ "$DEBUG" = true ]] && wait_keyboard || info End step "$step"
  info End step: "$step"
fi

#step 7
step=7
if [[ "$st" =~ "$step" ]]; then
  info Start step: "$step" 
  info Generation new release
  release "$PROJECT"
  cd "$MOODLE_SRC"
  git switch "$PROJECT" --quiet
  gitk
  info End step "$step"
fi
info "That's All!"