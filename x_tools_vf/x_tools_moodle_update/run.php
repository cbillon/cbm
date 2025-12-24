<?php

global $_CFG; // The tool's config.
global $_ARGS_ARG; // The arguments definition.
global $CFG; // If some tools load Moodle setup on init.
global $PATH; // The current path.
global $TOOLPATH; // The start path of the tool. The tool must revert to this location after processing.

$TOOLPATH = getcwd();

// Get sufficient parameters from command line.
$_ARGS_ARG = array('-d' => array('bind' => 'path', 'arg' => 1, 'mandatory' => FALSE),  // The starting path. Some commands do not need it (gitassemble)
             '-c' => array('bind' => 'command', 'arg' => 1, 'mandatory' => TRUE), // The comand to be executed
             '-r' => array('bind' => 'recurse', 'arg' => 0, 'mandatory' => FALSE),  // The command must be applied to sub pathes
             '-a' => array('bind' => 'args', 'arg' => 1, 'mandatory' => FALSE),  // Sub command argument string
             '-l' => array('bind' => 'lang', 'arg' => 1, 'mandatory' => FALSE),  // A working language can be defined for the operation
             '-C' => array('bind' => 'config', 'arg' => 1, 'mandatory' => FALSE),  // A config file where to find options
             '-m' => array('bind' => 'message', 'arg' => 1, 'mandatory' => FALSE),  // A textual message to pass to the command if it can use it
             '-v' => array('bind' => 'verbose', 'arg' => 0, 'mandatory' => FALSE),  // Should the scan be verbose on recursion ?
             '-h' => array('bind' => 'help', 'arg' => 0, 'mandatory' => FALSE)  // Give some help.
             );

make_config();

// Setting up command.
if (!file_exists($_CFG->realPathParts['dirname'] . "/" . $_CFG->command . ".php")){
    echo "FAILED : ". $_CFG->realPathParts['dirname'] . "/" . $_CFG->command . ".php... script does not exist\n";
    die;
}

include_once $_CFG->realPathParts['dirname'] . "/" . $_CFG->command . '.php';
$tool = new tool();

if (in_array('-h', $_SERVER['argv']) || in_array('--help', $_SERVER['argv'])){
    echo ("Usage : php.exe run -d <path> -c <phpcommandname> -r -a \"<argumentstring>\"\n");
    echo ("\t -d : path where to apply\n");
    echo("\t -c : the php command name in the x_tools directory\n");
    echo("\t -C : path to a global config file\n");
    echo("\t -r : if present, applies recursively\n");
    echo("\t -a : if present, an argument string to pass to the local command\n");
    echo("\t -l : if present, a working language for the current operation\n");
    echo("\t -m : if present, a textual message for the comand to consume it\n");
    echo("\t -v : if present, verboses the recursion scan\n");
    echo("\n");

    if (method_exists($tool, 'help')) {
        echo $tool->help();
    }

    exit(0);
}

// Launch the tool.

echo "init ".$_CFG->realPathParts['dirname'] . "/" . $_CFG->command . ".php\n";

$tool->init();

apply($_CFG->path, $tool);

$tool->finish();
chdir($TOOLPATH);

function apply($relpath, &$tool, $isroot = true) {
    global $_CFG, $CFG, $PATH;

    chdir($relpath);

    if (!empty($_CFG->verbose)) echo "----------------\n";
    $PATH = getcwd() . "\n";

    $_CFG->subargs = @$_CFG->args;
    $_CFG->mode = 'include';

    // What happens in child directory when arriving in.
    if (!empty($_CFG->verbose)) echo "PRE >> $PATH";
    $result = $tool->preprocess($isroot);
    if (!$result) {
        // Some conditions may stop the dig-in. 
        echo "Stopping recursion\n";
        if (!empty($_CFG->verbose)) echo "POST >> $PATH";
        $tool->postprocess($isroot);
        chdir('..');
        return;
    }

    // echo implode("\n", $output);
    if (!empty($_CFG->verbose)) echo "----------------\n";
    if (isset($_CFG->recurse)) {
        $DIR = opendir('.');
        while ($anEntry = readdir($DIR)) {
           if (preg_match("/^\./", $anEntry)) continue;
           if ($anEntry == 'CVS') continue;
           if (preg_match('/^x_/', $anEntry)) continue; // protect production dirs
           if (is_dir($anEntry)) {
                apply($anEntry, $tool, false);
           }
        }
        closedir($DIR);
    }

    // What happens in parent directory when coming back.
    if (!empty($_CFG->verbose)) echo "Post processing root...\n";
    $tool->postprocess($isroot);
    chdir('..');

    if (!empty($_CFG->verbose)) echo "Finishing...\n";
    $tool->finish();
    // Readjust path.
    $PATH = preg_replace('/\/[^\/]*$/', '', $PATH);
    if (!empty($_CFG->verbose)) echo "POST >> $PATH\n";
}

function make_config() {
    global $_CFG;
    global $_ARGS_ARG;

    $_CFG = new StdClass;

    $initialPath = getcwd();
    $realPath = realpath($_SERVER['SCRIPT_FILENAME']);
    $_CFG->realPathParts = pathinfo($realPath);
    $_CFG->exeToolsDir = dirname($realPath);

    // Magicallly detects OS.
    $sys = php_uname();
    $sysparts = explode(' ', $sys);
    $_CFG->os = $sysparts[0]; // Switch to Linux to get linux commands.

    $args = new StdClass;
    $args->commandLine = $_SERVER['argv'];
    array_shift($args->commandLine);

    $args->argumentNeeded = 0;
    $args->argCaptureCount = 0;
    $args->lastArg = '';
    $args->realArgs = array();

    foreach ($args->commandLine as $anArg) {
        if (preg_match("/^-/", $anArg)) {
            if ($args->argumentNeeded == 0) {
                $_CFG->{$_ARGS_ARG[$anArg]['bind']} = true;
            }
            if ($args->argumentNeeded > 0) die("missing argument for {$args->lastArg}\nAborting.\n");
            if ($args->argumentNeeded > 0 && $args->argumentNeeded == $args->argCaptureCount) die("not enough arguments for {$args->lastArg}\nAborting.\n");
            if (in_array($anArg, array_keys($_ARGS_ARG))){
                // echo "setarg "; 
                $args->argumentNeeded = $_ARGS_ARG[$anArg]['arg'];
                $args->argCaptureCount = 0;
                $args->lastArg = $anArg;
                $args->realArgs[] = $args->lastArg;
            }
        } else {
           // echo "setval ";
           if ($args->argumentNeeded > 1) {
              if ($args->argCaptureCount == 0) {
                 $_CFG->{$_ARGS_ARG[$args->lastArg]['bind']} = array($anArg);
                 $args->argCaptureCount++;
                 if ($args->argCaptureCount == $args->argumentNeeded) {
                    $args->argumentNeeded = 0;
                 }
              } else {
                 $_CFG->{$_ARGS_ARG[$args->lastArg]['bind']}[] = $anArg;
                 $args->argCaptureCount++;
              }
           } else {
              $_CFG->{$_ARGS_ARG[$args->lastArg]['bind']} = $anArg;
              $args->argumentNeeded = 0;
           }
        }
    } 
    // Check last arg position.
    if ($args->argCaptureCount != $args->argumentNeeded) {
        die("missing argument for {$args->lastArg}\nAborting.\n");
    }

    $mandatoryArgs = array_filter(array_keys($_ARGS_ARG), "mandatories");
    $args->diffArgs = array_diff($mandatoryArgs, $args->realArgs);
    if (!empty($args->diffArgs) && !isset($_CFG->help)) {
        die("missing parameters " . implode(",", $args->diffArgs) . "\nAborting.\n");
    }

    // Finally decode command args if any
    if (!empty($_CFG->args)) {
        decode_subcommand_args();
    }
}

function mandatories($a){
    global $_CFG;
    global $_ARGS_ARG;
    return $_ARGS_ARG[$a]['mandatory'];
}

function decode_subcommand_args() {
    global $_CFG;

    $parts = preg_split('/\s+/', $_CFG->args);
    $_CFG->command_params = new StdClass;
    foreach ($parts as $p) {
        $arr = explode(':', $p);
        if (count($arr) != 2) {
            die('Error in subcommand params. Must be "k1:token1 k2:token2" form');
        }

        list($k, $v) = $arr;
        $_CFG->command_params->$k = $v;
    }

    // Add message to subcommand params
    if (!empty($_CFG->message)) {
        $_CFG->command_params->message = $_CFG->message;
    }
}

function localreadline($prompt = null) {
    if($prompt){
        echo $prompt;
    }
    $fp = fopen("php://stdin","r");
    $line = rtrim(fgets($fp, 1024));
    return $line;
}