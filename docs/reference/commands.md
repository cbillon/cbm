# CodeBaseManager Commands 


List des commandes du menu

- add_plugin_cache
- list_plugins_cache
- edit_plugins 
- add_plugin_project  
- update_moodle 
- update_repo             
- update_codebase           
- release  
- help 

function info()
function warn()
function error()
function success()
function check_command()
 si erreur dans la commande précédente ($? -ne 0) message FUNCTION LINENO command 
function get_pluglist () 
 upload pluglist.json liste des plugins si date dernier chargement > $DIFF_DAYS
function get_reqested_state () 
 param : $PROJECT
 set PROJECT_BRANCH=$PROJECT
 verifie existence et syntaxe $PROJECTS_PATH/$PROJECT/$PROJECT.yml
 détermine : MOODLE_VERSION
             MOODLE_MAJOR_VERSION
             MOODLE_BRANCH  branche de Moodle corresondant à la version majeure   
function create_file () 
  create file if not exists
function create_dir () 
  create dir if not exists
function verif_pre_requis () 
  check exists git jq yq
function create_env () 
  create_dir $DEPOT_MODULES
  create_dir $PROJECTs_PATH
  PROJECT='demo'
function new_project () 
  creer les repertoires et fichiers du projet
  demande version Moodle
  call create_project_repo $PROJECT
function get_current_state () 
function create_project_repo ()
  param : $PROJECT
  load_cnf $PROJECT
  existe $MODDLE_SRC ?
  existe $MODDLE_BRANCH ? 
function update_moodle () 
function list_plugins_cache () 
function add_plugin_cache () 
function add_plugin_project () 
function select_plugin_branch () 
function config_check () 
function edit_plugins ()  
function update_repo ()   
function upgrade_plugin () 
function import_plugin () 
function set_plugin ()   
function subrepo_plugin ()  
function update_codebase () 
function release () 
function project_lock () 
function suppress_plugin () 
function nothingtodo () 
function help () 
