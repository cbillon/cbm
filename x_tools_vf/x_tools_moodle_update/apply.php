<?php

global $_CFG;
global $ARGS_ARG;
global $CFG;
global $PATH;
global $TOOLPATH;

$TOOLPATH = getcwd();
$moodleroot = 'C:/wwwroot64';

// get sufficient parameters from command line
$ARGS_ARG = array('-d' => array('bind' => 'path', 'arg' => 1, 'mandatory' => TRUE),  // The starting path
             '-c' => array('bind' => 'command', 'arg' => 1, 'mandatory' => TRUE), // The comand to be executed
             '-r' => array('bind' => 'recurse', 'arg' => 0, 'mandatory' => FALSE),  // The command must be applied to sub pathes
             '-a' => array('bind' => 'args', 'arg' => 1, 'mandatory' => FALSE),  // Sub command argument string
             '-l' => array('bind' => 'lang', 'arg' => 1, 'mandatory' => FALSE),  // A working language can be defined for the operation
             '-C' => array('bind' => 'config', 'arg' => 1, 'mandatory' => FALSE),  // A working language can be defined for the operation
             '-v' => array('bind' => 'verbose', 'arg' => 0, 'mandatory' => FALSE),  // Should the scan be verbose on recursion ? 
             '-B' => array('bind' => 'branches', 'arg' => 1, 'mandatory' => FALSE),  // give branch list 
             '-m' => array('bind' => 'message', 'arg' => 1, 'mandatory' => FALSE)  // a commit message if the command accepts messages
             );

$_CFG = new StdClass;
$ARGS = new StdClass;
$ARGS->argumentNeeded = 0;
$ARGS->argCaptureCount = 0;
$ARGS->lastArg = '';
$ARGS->realArgs = [];

if (in_array('-h', $_SERVER['argv']) || in_array('--help', $_SERVER['argv'])){
    echo ("Applies a local command to several codbases\n");
    echo ("Usage : php.exe applyToDir -d <path> -c <phpcommandname> -r -a \"<argumentstring>\"\n");
    echo ("\t -d : path where to apply\n");
    echo("\t -c : the php command name in the x_tools directory\n");
    echo("\t -C : path to a global config file\n");
    echo("\t -r : if present, applies recursively\n");
    echo("\t -a : if present, an argument string to pass to the local command\n");
    echo("\t -l : if present, a working language for the current operation\n");
    echo("\t -B : if present, a comma separared list of branch numbers (XX)\n");
    echo("\t -m : if present, textual message to give to the command if it can consume it\n");
    echo("\t -v : if present, verboses the recursion scan\n");
    echo("\n");
    exit(0);
}

$handled = array('39', '41', '45');

$_ARGS = new StdClass;
$_ARGS->commandLine = $_SERVER['argv'];
array_shift($_ARGS->commandLine);

foreach($_ARGS->commandLine as $anArg){
    if (preg_match("/^-/", $anArg)){
        if ($ARGS->argumentNeeded == 0) {
            $_CFG->{$ARGS_ARG[$anArg]['bind']} = TRUE;
        }
        if ($ARGS->argumentNeeded > 0) die("missing argument for {$ARGS->lastArg}\nAborting.\n");
        if ($ARGS->argumentNeeded > 0 && $ARGS->argumentNeeded == $ARGS->argCaptureCount) die("not enough arguments for {$ARGS->lastArg}\nAborting.\n");
        if (in_array($anArg, array_keys($ARGS_ARG))){
            // echo "setarg "; 
            $ARGS->argumentNeeded = $ARGS_ARG[$anArg]['arg'];
            $ARGS->argCaptureCount = 0;
            $ARGS->lastArg = $anArg;
            $ARGS->realArgs[] = $ARGS->lastArg;
        }
    }
    else{
       // echo "setval ";
       if ($ARGS->argumentNeeded > 1){
          if ($ARGS->argCaptureCount == 0){
             $_CFG->{$ARGS_ARG[$ARGS->lastArg]['bind']} = array($anArg);
             $ARGS->argCaptureCount++;
             if ($ARGS->argCaptureCount == $ARGS->argumentNeeded){
                $ARGS->argumentNeeded = 0;
             }
          }
          else{
             $_CFG->{$ARGS_ARG[$ARGS->lastArg]['bind']}[] = $anArg;
             $ARGS->argCaptureCount++;
          }
       }
       else{
          $_CFG->{$ARGS_ARG[$ARGS->lastArg]['bind']} = $anArg;
          $ARGS->argumentNeeded = 0;
       }
    }
}
// check last arg position.
if ($ARGS->argCaptureCount != $ARGS->argumentNeeded){
    die("missing argument for {$ARGS->lastArg}\nAborting.\n");
}

function mandatories($a) {
    global $_CFG;
    global $ARGS_ARG;
    return $ARGS_ARG[$a]['mandatory'];
}

$mandatoryArgs = array_filter(array_keys($ARGS_ARG), "mandatories");
$ARGS->diffArgs = array_diff($mandatoryArgs, $ARGS->realArgs);
if (!empty($ARGS->diffArgs)){
    die("missing parameters " . implode(",", $ARGS->diffArgs) . "\nAborting.\n");
}

if (!empty($_CFG->branches)) {
    $branchlist = explode(',', $_CFG->branches);
    foreach ($branchlist as $branch) {
        // Drop all items that are not handled.
        if (in_array($branch, $handled)) {
            $branches[] = $branch;
        }
    }
} else {
    $branches = $handled;
}

$command = $_CFG->command;
$recurse = (!empty($_CFG->recurse)) ? '-r' : '';
$verbose = (!empty($_CFG->verbose)) ? '-v' : '';
$directory = $_CFG->path;
$arguments = (!empty($_CFG->args)) ? ' -a "'.$_CFG->args.'" ' : '';

// Asked for prompting.
if ('?' == @$_CFG->message) {
    $message = '-m "'.localreadline('Message> :').'"';
} else {
    $message = (!empty($_CFG->message)) ? '-m "'.$_CFG->message.'"' : '';
}

if (!empty($branches)) {
    foreach ($branches as $b) {
        chdir($moodleroot.'/moodle_'.$b.'_generic/x_tools');
        $cmd = 'php applyToDir.php -c '.$_CFG->command.' '.$verbose.' '.$recurse.' -d '.$directory.' '.$arguments.' '.$message;
        echo getcwd().'> '.$cmd."\n";
        $res = exec($cmd, $output, $resultvar);
        echo implode("\n", $output);
    }
}

chdir($TOOLPATH);

/* ********* Local functions *********************/

function localreadline($prompt = null){
    if($prompt){
        echo $prompt;
    }
    $fp = fopen("php://stdin","r");
    $line = rtrim(fgets($fp, 1024));
    return $line;
}