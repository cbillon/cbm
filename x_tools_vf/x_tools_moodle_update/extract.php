<?php
date_default_timezone_set('UTC');
$date = date("l dS of F Y h:i:s A", time());
echo "production tool : extract\n$date\n
By Valery Fremaux 2007 for Moodle (valery.fremaux@gmail.com)
---------------------------\n";

require_once('classes/yaml_wrapper.php');
require_once('classes/toollib.php');

use tool\tool_base;

// A global tool must assume acting in current directory.

class tool extends tool_base {

    public $trace = null;

    public $hardconfig = null;

    public $receipetemplate = [
        'targets' => 'targets',
        'core' => 'core',
        'override' => 'override',
        'plugins' => 'plugins',
        'config' => 'config',
        'options' => [
            'withcore' => 'false',
            'forcecreatedirs' => 'true',
            'forceinstall' => 'true',
            'debug' => 'true',
            'ignorefailing' => 'true',
            'errortrace' => 'false',
            'processcustomscripts' => 'false',
            'processpatchs' => 'false',
            'preferprivate' => 'true'
        ],
    ];

    function help() {
        $help = "

Subcommand Help :

        --path: the base path of the moodle to extract
        --withcore: integrates also core files when rebuilding
";

        return $help;
    }

    // Runs only once at start of the tool.
    public function init() {
        global $PATH;
        global $gitroot;
        global $rsyncgitroot;
        global $rsynccoreroot;
        global $_CFG; // Tool config.
        global $CFG; // Moodle config.
        global $SITE; // Moodle Site.

        echo "Connecting to moodle...\n";

        // Get moodle version.
        if (!file_exists($_CFG->path.'/version.php')) {
            throw new Exception("Path {$_CFG->path} does not contain a moodle instance. Probably argument -d not set for extract command.\n");
        }

        define('CACHE_DISABLE_ALL', true);

        // Get hard config.
        $this->hardconfig = null;
        if (file_exists($_CFG->path.'/config.php')) {
            if (!empty($_CFG->verbose)) echo "Getting config info... \n";
            define('ABORT_AFTER_CONFIG', true);
            // This is a properly installed Moodle with config file.
            include($_CFG->path.'/config.php');
            $this->hardconfig = clone($CFG);

            // Reload full config.
            define('ABORT_AFTER_CONFIG_CANCEL', true);
            include($_CFG->path.'/config.php');
        } else {
            if (!empty($_CFG->verbose)) echo "Making minimal config... \n";
            // Build a minimalist config.
            define('MOODLE_INTERNAL', 1);
            define('CLI_SCRIPT', true);
            define('SYSCONTEXTID', 1);
            $CFG = new StdClass;
            $SITE = new StdClass;
            $CFG->dirroot = $_CFG->path;
            $CFG->dataroot = '/data/moodledata';
            $CFG->cachedir = '/data/moodledata/cache';
            $CFG->wwwroot = 'https://dummy.dummy.org';
            $CFG->dbtype = 'mariadb';
            $CFG->dbhost = 'localhost';
            $CFG->dbname = '';
            $CFG->dblogin = '';
            $CFG->dbpassword = '';
            $SITE->fullname = 'Receipe extraction';
            $SITE->shortname = 'EXTRACT';

            $CFG->libdir = $_CFG->path.'/lib';
            $CFG->admin = 'admin';
            $CFG->debug = false;
            $CFG->debugdisplay = false;
            $CFG->debugdeveloper = 0;
            $CFG->langotherroot = '';
            $CFG->langlocalroot = '';

            if (!empty($_CFG->verbose)) echo "Loading moodle libraries... \n";

            // Load up standard libraries
            require_once($CFG->libdir .'/setuplib.php');        // Functions that MUST be loaded first
            require_once($CFG->libdir .'/classes/component.php');
            require_once($CFG->libdir .'/classes/plugin_manager.php');
            require_once($CFG->libdir .'/filterlib.php');       // Functions for filtering test as it is output
            require_once($CFG->libdir .'/ajax/ajaxlib.php');    // Functions for managing our use of JavaScript and YUI
            require_once($CFG->libdir .'/weblib.php');          // Functions relating to HTTP and content
            require_once($CFG->libdir .'/outputlib.php');       // Functions for generating output
            require_once($CFG->libdir .'/navigationlib.php');   // Class for generating Navigation structure
            require_once($CFG->libdir .'/dmllib.php');          // Database access
            require_once($CFG->libdir .'/datalib.php');         // Legacy lib with a big-mix of functions.
            require_once($CFG->libdir .'/accesslib.php');       // Access control functions
            require_once($CFG->libdir .'/deprecatedlib.php');   // Deprecated functions included for backward compatibility
            require_once($CFG->libdir .'/moodlelib.php');       // Other general-purpose functions
            require_once($CFG->libdir .'/enrollib.php');        // Enrolment related functions
            require_once($CFG->libdir .'/pagelib.php');         // Library that defines the moodle_page class, used for $PAGE
            require_once($CFG->libdir .'/blocklib.php');        // Library for controlling blocks
            require_once($CFG->libdir .'/grouplib.php');        // Groups functions
            require_once($CFG->libdir .'/sessionlib.php');      // All session and cookie related stuff
            require_once($CFG->libdir .'/editorlib.php');       // All text editor related functions and classes
            require_once($CFG->libdir .'/messagelib.php');      // Messagelib functions
            require_once($CFG->libdir .'/modinfolib.php');      // Cached information on course-module instances
            require_once($CFG->dirroot.'/cache/lib.php');       // Cache API


            //point pear include path to moodles lib/pear so that includes and requires will search there for files before anywhere else
            //the problem is that we need specific version of quickforms and hacked excel files :-(
            ini_set('include_path', $CFG->libdir.'/pear' . PATH_SEPARATOR . ini_get('include_path'));

            // Register our classloader, in theory somebody might want to replace it to load other hacked core classes.
            if (defined('COMPONENT_CLASSLOADER')) {
                spl_autoload_register(COMPONENT_CLASSLOADER);
            } else {
                spl_autoload_register('core_component::classloader');
            }

            if (!empty($_CFG->verbose)) echo "Working with minimal config... \n";
        }

        $gitroot = 'E:/gitrepos';
        $rsyncgitroot = '/cygdrive/e/gitrepos';
        $rsynccoreroot = '/cygdrive/c/wwwroot64';
    }

    // Runs as soon as digging down into the directory.
    // No care it is root as we look for explicit codeincrement extra attribute.
    public function preprocess($isroot = false) {
        global $PATH;
        global $_CFG;
        global $CFG;
        global $TOOLPATH;
        global $COREROOT;
        global $rsyncgitroot;
        global $rsynccoreroot;
        global $gitroot;
        global $moodleroot;

        if (!empty($_CFG->verbose)) echo "Starting preprocessing... ";

        $receipe = [];

        include_once(trim($PATH).'/version.php');
        $receipe['core'] = $branch;
        $receipe['override'] = $branch;
        $CFG->branch = $branch;

        // Get all additional plugins.
        $pluginman = core_plugin_manager::instance();
        $plugininfo = $pluginman->get_plugins();

        $allcount = count($plugininfo, COUNT_RECURSIVE);
        $typecount = count($plugininfo, COUNT_NORMAL);
        $allpluginscount = $allcount - $typecount;

        $j = 0;
        $retained = 0;
        $count = 0;
        foreach ($plugininfo as $type => $plugins) {
            foreach ($plugins as $name => $plugin) {
                $count++;
            }
        }

        foreach ($plugininfo as $type => $plugins) {
            foreach ($plugins as $name => $plugin) {
                if (!$plugin->is_standard() && !$plugin->is_subplugin()) {
                    // Subplugins are installed by plugin distribution.
                    $receipe['plugins'][] = $type.'_'.$name;
                    $retained++;
                }
                $j++;
                echo "\r $j / $allpluginscount       retained($retained)                  ";
                usleep(50); // Let allow see something.
            }
        }
        echo "\r\n";

        // Get hard config values.
        if (!is_null($this->hardconfig)) {
            foreach($this->hardconfig as $name => $value) {
                $receipe['config'][$name] = $value;
            }
        }

        // Get default values (options) from template.
        $receipe['options'] = new StdClass; // At the moment. 

        $options = new Stdclass;
        foreach ($this->receipetemplate['options'] as $key => $default) {
            if (!property_exists($receipe['options'], $key)) {
                $options->$key = $this->receipetemplate['options'][$key];
            } else {
                $options->$key = $receipe['options']->$key;
            }
            $receipe['options'] = $options;
        }

        $yml = $this->write_yaml($receipe);

        if (isset($_CFG->config['output'])) {
            $ymlfile = $_CFG->config['output'];
        } else {
            $ymlfile = $TOOLPATH.'/receipe_'.basename($_CFG->path).'.yml';
        }

        if (!$YML = fopen($ymlfile, 'w')) {
            throw new Exception("Cannot write output to $YML\n");
        }
        fputs($YML, $yml);
        fclose($YML);

        if (!empty($_CFG->verbose)) echo "Ending preprocessing... \n";

        return true;
    }

    // Runs after returning up to the calling directory.
    public function postprocess($isroot) {
        return false;
    }

    // Runs only once at end of the tool execution.
    public function finish() {
        $this->trace();
        $this->trace('Done.');
        $this->trace();
    }

    function trace($message = '') {
        echo $message."\n";
        if (!empty($this->trace)) {
            fputs($this->trace, $message."\n");
        }
    }

    protected function write_yaml($receipe) {
        $INDENT = '    ';
        $str = '# Yaml_writer generated '.date('Y/m/d')."\n";
        $str .= "#\n";
        $str .= "\n";

        foreach ($receipe as $section => $items) {
            $str .= $section.':'."\n";
            if (is_array($items)) {
                foreach ($items as $item) {
                    $str .= $INDENT."- ".$item."\n";
                }
            } else if (is_object($items)) {
                foreach ($items as $property => $value) {
                    $str .= $INDENT.$property.': '.$value."\n";
                }
            } else {
                // scalar
                $str .= $INDENT.$items."\n";
            }
            $str .= "\n";
        }
        return $str;
    }

    protected function print_progress($counter, $total) {
        $ratio = round($counter / $total);
        echo "\ranalysing : $ratio%                   ";
    }
}

