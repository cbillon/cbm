<?php
date_default_timezone_set('UTC');
$date = date("l dS of F Y h:i:s A", time());
echo "production tool : assemble\n$date\n
By Valery Fremaux 2007 for Moodle (valery.fremaux@gmail.com)
---------------------------\n";

require_once('classes/yaml_wrapper.php');
require_once('classes/moodle_api_wrapper.php');
require_once('classes/patches.class.php');

use tool\yaml_parser;
use tool\patches;
use tool\moodle_plugins_remote;

// A global tool must assume acting in current directory.

if (!defined('MOODLE_INTERNAL')) {
    define('MOODLE_INTERNAL', 1);
}

/** Software maturity level - internals can be tested using white box techniques. */
define('MATURITY_ALPHA',    50);
/** Software maturity level - feature complete, ready for preview and testing. */
define('MATURITY_BETA',     100);
/** Software maturity level - tested, will be released unless there are fatal bugs. */
define('MATURITY_RC',       150);
/** Software maturity level - ready for production deployment. */
define('MATURITY_STABLE',   200);

class tool {

    public $trace = null;

    public $patchprocessor = null;

    function help() {
        $help = "

Subcommand Help :

        --rfile: the receipe file to execute
        --withcore: integrates also core files when rebuilding
        --force: force creation of plugin dirs
        --target: If not set in receipe, the output directory for assembled code (single target)

        Subcommand param string syntax : -a=\"<opt1>:<value1> <opt2>:<value2>\"
";

        return $help;
    }

    // Runs only once at start of the tool.
    function init() {
        global $gitroot;
        global $rsyncgitroot;
        global $rsynccoreroot;
        global $_CFG;

        if (is_dir('/etc')) {
            $_CFG->ostype = 'linux';
        } else {
            $_CFG->ostype = 'WINDOWS';
        }

        echo "Initialising code assembler...\n";

        $gitletter = "G";
        $gitroot = 'G:/gitrepos';
        $rsyncgitroot = '/mnt/g/gitrepos';
        $rsynccoreroot = '/mnt/c/wwwroot64';

        if (!is_dir($rsyncgitroot)) {
            // Try remount volume
            $cmd = "mount -t drvfs {$gitletter}: /mnt/".strtolower($gitletter);
            exec($cmd);

            if (!is_dir($rsyncgitroot)) {
                die("Fatal error : Gitroot not accessible at : $rsyncgitroot \nVolume may be dismounted.\n");
            }
        }

        if (!is_dir($rsynccoreroot)) {
            die("Fatal error : Core root not accessible at : $rsynccoreroot \n");
        }

        if (!empty($_CFG->command_params->rfile)) {
            if (!file_exists($_CFG->command_params->rfile)) {
                $this->trace('FATAL ERROR: Receipe file does not exist. Check file name');
                die;
            }
            $yaml = implode('', file($_CFG->command_params->rfile));
            $_CFG->config = yaml_parser::parse($yaml);
        }

        // Fix targets if explicitely required
        if (empty($_CFG->config['targets'])) {
            if (!empty($_CFG->command_params->target)) {
                $_CFG->config['targets'] = [$_CFG->command_params->target];
            } else {
                print_r($_CFG->config);
                throw new Exception("No targets were defined, nor in receipe (targets), nor in command attributes (target)\n");
            }
        }

        //start pattern consider a full line patch mark pattern 
        $_CFG->patchstartpattern = "\\s*\/\/\/?\\s*(PATCH |PATCH+)[^\\n]*\\n";

        //end pattern consider a full line patch mark pattern 
        $_CFG->patchendpattern = "\\n*\\s*\/\/\/?\\s*(\/PATCH|PATCH-)\\s*";

        //the number of lines over the start patch pattern for reintegration location
        $_CFG->scanaroundlinesover = 4;

        //the number of lines beneath the end patch pattern for reintegration location
        $_CFG->scanaroundlinesbeneath = 4;

        //start pattern consider a full line patch mark pattern will need /s modifier
        $_CFG->scanaroundupperpattern = "(?:[^\\n]*\\n){1,{$_CFG->scanaroundlinesover}}";

        //end pattern consider a full line patch mark pattern 
        $_CFG->scanaroundlowerpattern = "(?:[^\\n]*\\n){1,{$_CFG->scanaroundlinesbeneath}}";
    }

    // Runs as soon as digging down into the directory.
    // No care it is root as we look for explicit codeincrement extra attribute.
    function preprocess($isroot = false) {
        global $PATH;
        global $_CFG;
        global $TOOLPATH;
        global $COREROOT;
        global $rsyncgitroot;
        global $rsynccoreroot;
        global $gitroot;
        global $moodleroot;

        $handledversions = [39, 41, 45];

        echo "working in ".getcwd()."\n";
        if (!empty($_CFG->config['options']['debug'])) {
            print_r($_CFG->config);
        }

        // Can divert customscripts to any directory
        if (empty($_CFG->config['customscripts'])) {
            $_CFG->config['customscripts'] = '/customscripts';
        }

        if (!empty($_CFG->config['options']['errortrace'])) {
            $this->trace = fopen($TOOLPATH.'/'.$_CFG->config['options']['errortrace'], 'w');
        }

        $api = new moodle_plugins_remote();
        $api->init();

        foreach ($_CFG->config['targets'] as $t) {

            // $t is the root code dir of the moodle target.
            $baseroot = dirname($t);
            $COREROOT = $baseroot.'/moodle_'.$_CFG->config['core'].'_core';
            $GENERICROOT = $baseroot.'/moodle_'.$_CFG->config['core'].'_generic';

            // Make a processor to process patches and customscripts.
            $this->patchprocessor = new patches($COREROOT, $t, $this);

            $cygt = str_replace('C:', '/mnt/c', $t);

            // $cygt is the root code dir of the moodle target for cygwin toolkit.

            /// Rsync master core code.

            if (empty($_CFG->config['options']['withcore'])) {
                // Override receipe file with command line.
                if (!empty($_CFG->command_params->withcore)) {
                    $_CFG->config['options']['withcore'] = $_CFG->command_params->withcore;
                }
            }

            if (($_CFG->config['options']['withcore'] == 'true') || 
                    ($_CFG->config['options']['withcore'] == 'once')) {
                        // Any cases where we want core.

                if (($_CFG->config['options']['withcore'] == 'once') && file_exists($t.'/index.php')) {
                    $this->trace("Core: WARNING: Core in place and must installed once. Skipping.");
                } else {

                    $this->trace('Core: syncing core code...');
                    $rsynccoredir = $rsynccoreroot.'/moodle_'.$_CFG->config['core'].'_core';

                    $verbose = '';
                    if (!empty($_CFG->config['options']['debug'])) {
                        $verbose = " --info=progress2 ";
                    }

                    if (is_dir($COREROOT)) {
                        $rsynccmd = 'rsync -r --delete --exclude=".git" --exclude=".svn" '.$verbose.' '.$rsynccoredir.'/* '.$cygt;
                        $descriptorspec = [STDIN, STDOUT, STDOUT];
                        $pipes = [];
                        $PROC = proc_open($rsynccmd, $descriptorspec, $pipes);
                        proc_close($PROC);
                    } else {
                        $this->trace("Core: ERROR: no core code found for {$_CFG->config['core']} in $COREROOT");
                        die;
                    }
                }
            } else {
                $this->trace('Core: syncing core. Disabled ...disabled.');
            }


            if (array_key_exists('override', $_CFG->config)) {

                $this->trace('Core: syncing core overrides...');
                $overridedir = $rsynccoreroot.'/moodle_'.$_CFG->config['override'].'_patch';
                $verbose = '';
                if (!empty($_CFG->config['options']['debug'])) {
                    $verbose = " --info=progress2 ";
                }
                if (is_dir($overridedir)) {
                    $rsynccmd = 'rsync -r --exclude=".git" --exclude=".svn" '.$verbose.' '.$rsynccoreroot.'/moodle_'.$_CFG->config['override'].'_patch/ '.$cygt;
                    $descriptorspec = [STDIN, STDOUT, STDOUT];
                    $pipes = [];
                    $PROC = proc_open($rsynccmd, $descriptorspec, $pipes);
                    proc_close($PROC);
                }
            }

            /// Process plugins.

            $MOODLE_BRANCH = 'MOODLE_'.$_CFG->config['core'].'_STABLE';

            foreach ($_CFG->config['plugins'] as $p) {

                $this->trace();
                $p = trim($p);

                /*
                 * We check if we prefer the private variant of the plugin and the
                 * plugin has a private variant available. Otherwise we should explicit
                 * the _P suffix in the plugin list.
                 * This addresses localgit deposits.
                 */
                if (!empty($_CFG->config['options']['preferprivate']) && !preg_match('/_P$/', $p)) {
                    // Prepare for private release.
                    $P = $p.'_P';
                    if (is_dir($rsyncgitroot.'/moodle-'.$P)) {
                        // Confirm that we use the private one.
                        $p = $P;
                    }
                }

                // Get upstream definition with attribute.
                // This allows to fetch a plugin on any git accessible repository, when
                // not available locally or via moodle.org plugin directory.
                $remotegit = false;
                if (preg_match('/--upstream ([^-]*)/', $p, $matches)) {
                    $remotegit = true;
                    $remoteref = $matches[1];
                    if (preg_match('/--branch ([^-]*)$/', $p, $matches)) {
                        $remotebanch = $matches[1];
                    }

                    // Extract plugin basename.
                    preg_match('/^\S+/', $p, $matches);
                    $p = $matches[0];

                } else {
                    // No upstream, so local repo.
                    // Divert to private repository if unreleased.

                    $current = getcwd();

                    $allowother = false;
                    if (preg_match('/--allow-other/', $p)) {
                        // Do we allow taking another branch than the master branch ?
                        $allowother = true;
                    }

                    if (preg_match('/--allow-older/', $p)) {
                        // Do we allow taking another branch than the master branch ?
                        $allowolder = true;
                    }

                    // Extract plugin basename.
                    preg_match('/^\S+/', $p, $matches);
                    $p = $matches[0];

                    // Check we can find a local repo matching the plugin in our local GIT
                    // If not found, there might be a remote git repo provided by the
                    // developper.
                    // At the moment we will not assemble non local githandled remote plugins.
                    // @TODO : add some way to document the remote plugin location.
                    // f.e. adding a --upstream=<giturl> in the plugin line.
                    // or adding a sources section to the yaml file to give pluginname => "source git url" mapping.

                    $localgit = false;
                    if (is_dir($rsyncgitroot.'/moodle-'.$p)) {
                        // This is one of our plugins.

                        $plugin = new StdClass;
                        $module = new StdClass; // For some old plugins.
                        $this->trace('Opening '.$rsyncgitroot.'/moodle-'.$p.'/version.php');
                        include($rsyncgitroot.'/moodle-'.$p.'/version.php');
                        if (!empty($plugin->codeincrement)) {
                            $localgit = true;
                        }
                    }
                }

                /// Plugin is detected as local 
                if ($localgit) {

                    // Move shell to git repo and switch branch to our version.
                    chdir($rsyncgitroot.'/moodle-'.$p);

                    // Checkout the expected branch
                    echo "checkouting...\n";
                    $cmd = 'git checkout '.$MOODLE_BRANCH;
                    $res = exec($cmd, $output, $returnvar);
                    if ($returnvar) {
                        // On failure, returnvar is 1.
                        // if (!in_array($version, $handledversions)) {
                            $message = 'Git branch switch failed. It may be missing on plugin '.$p;
                            if (empty($_CFG->config['options']['ignorefailing'])) {
                                $this->trace($message);
                                die;
                            }

                            if (!empty($_CFG->config['options']['errortrace'])) {
                                $this->trace($message);
                            }
                        // }
                    }

                    // Move shell to component location and switch branch to our version.
                    // Remove private extension if present.
                    $component = str_replace('_P', '', $p);
                    $componentpath = resolve_location($component, $_CFG->config['core']);
                    $this->trace("Changing to {$t}{$componentpath}");
                    if (!is_dir($t.$componentpath)) {
                        if (empty($_CFG->command_params->force) && empty($_CFG->config['options']['forcecreatedirs'])) {
                            $message = localreadline('Force creation of missing directory? (y/n)');
                            if ($message == 'y') {
                                mkdir($t.$componentpath, 0777, true);
                                $this->trace("      ...creating dir $t$componentpath ... ");
                            } else {
                                continue;
                            }
                        } else {
                            mkdir($t.$componentpath, 0777, true);
                            $this->trace("      ...creating dir  $t$componentpath... \n");
                        }
                    }
                    chdir($t.$componentpath);

                    // rsync/push code using cwrsync wrapper.
                    // We take care of rsyncing also hidden files such as travis.
                    $this->trace('syncing plugin code...');
                    if (!empty($_CFG->config['options']['debug'])) {
                        $verbose = " --info=progress2 ";
                    }
                    $rsynccmd = 'rsync -r --delete --exclude=".git" '.$verbose.' '.$rsyncgitroot.'/moodle-'.$p.'/ .';
                    $descriptorspec = [STDIN, STDOUT, STDOUT];
                    $pipes = [];
                    $PROC = proc_open($rsynccmd, $descriptorspec, $pipes);
                    proc_close($PROC);

                    // Apply patchs and customscripts.
                    if (is_dir('__patch') && !empty($_CFG->config['options']['processpatchs'])) {
                        $this->patchprocessor->apply_patchs($t, '', $componentpath.'/__patch', $this);
                    }

                    if (is_dir('__customscripts') && !empty($_CFG->config['options']['processcustomscripts'])) {
                        $this->patchprocessor->apply_customscripts($t, $_CFG->config['customscripts'], $componentpath.'/__customscripts', $this);
                    }

                    $this->trace('coming back...');
                    chdir($current);
                } else if ($remotegit) {
                    // the repo is an extra git somewhere.
                    // Use git clone to get a local copy, or git pull to get last repo state if exists.
                    $message = "PLUGIN MISSING : Get $p manually.";
                    if (empty($_CFG->config['options']['ignorefailing'])) {
                        $this->trace($message);
                        die;
                    } else {
                        $this->trace($message);

                        if (!empty($_CFG->config['options']['errortrace'])) {
                            $this->trace($message);
                        }
                        continue;
                    }

                } else {
                    if (!empty($_CFG->config['options']['skipnetworking'])) {
                        $this->trace("PLUGIN WARNING: Networking skipped by configuration. $p not available.");
                        continue;
                    }
                    // Get it directly from Moodle.org plugin base.
                    $plugininfo = $api->get_latest_version($p, ANY_VERSION, $_CFG->config['core']);

                    if (!$plugininfo) {
                        $message = "PLUGIN ERROR : The remote plugin source for $p is not responding. Ignoring.";
                        if (empty($_CFG->config['options']['ignorefailing'])) {
                            $this->trace($message);
                            die();
                        } else {
                            $this->trace($message);
                            continue;
                        }
                    } else {
                        if (!isset($plugininfo->version->vcsbranch)) {
                            $plugininfo->version->vcsbranch = $MOODLE_BRANCH;
                        }

                        if (!isset($plugininfo->version->version)) {
                            $plugininfo->version->version = 'UNDEF';
                        }

                        $message = "Plugin:\n";
                        $message .= "name: {$plugininfo->component}\n";
                        $message .= "url: {$plugininfo->version->downloadurl}\n";
                        $message .= "branch: {$plugininfo->version->vcsbranch}\n";
                        $message .= "release: {$plugininfo->version->release}\n";
                        $message .= "version: {$plugininfo->version->version}";
                        $this->trace();
                        $this->trace($message);
                        $this->trace();
                    }

                    // We do not have the adequate version, and we do not allow other versions.
                    if ($plugininfo->version->vcsbranch < $MOODLE_BRANCH && (!$allowolder && !$allowother)) {

                        $this->trace('VCS Branch mismatch. Trying with release');
                        $release = $plugininfo->version->release;
                        $release = preg_replace('/[\D]/', '', $release); // Eliminate non numeric chars.
                        if (!preg_match('/^'.$_CFG->config['core'].'/', $release)) {

                            $this->trace('Last chance. analysing supported versions');
                            if (!empty($plugininfo->version->supportedmoodles)) {
                                $found = false;
                                foreach ($plugininfo->version->supportedmoodles as $sm) {
                                    $release = preg_replace('/[\D]/', '', $sm->release); // Eliminate non numeric chars.
                                    if (preg_match('/^'.$_CFG->config['core'].'/', $release)) {
                                        $found = true;
                                        break;
                                    }
                                }

                                if (!$found && empty($_CFG->config['options']['forceinstall'])) {
                                    $message = 'All checks failed on '.$p.'. Possible version misfit. check moodle.org avalability.';
                                    if (!empty($_CFG->config['options']['debug'])) {
                                        print_r($plugininfo);
                                    }

                                    if (!empty($_CFG->config['options']['errortrace'])) {
                                        $this->trace($message);
                                    }

                                    if (empty($_CFG->config['options']['ignorefailing'])) {
                                        $this->trace($message);
                                        die();
                                    } else {
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                    else if (($plugininfo->version->vcsbranch > $MOODLE_BRANCH) && !$allowother) {

                        $this->trace('VCS Branch mismatch. Trying with release');
                        $release = $plugininfo->version->release;
                        $release = preg_replace('/[\D]/', '', $release); // Eliminate non numeric chars.
                        if (!preg_match('/^'.$_CFG->config['core'].'/', $release)) {

                            $this->trace('Last chance. analysing supported versions');
                            if (!empty($plugininfo->version->supportedmoodles)) {
                                $found = false;
                                foreach ($plugininfo->version->supportedmoodles as $sm) {
                                    $release = preg_replace('/[\D]/', '', $sm->release); // Eliminate non numeric chars.
                                    if (preg_match('/^'.$_CFG->config['core'].'/', $release)) {
                                        $found = true;
                                        break;
                                    }
                                }

                                if (!$found && empty($_CFG->config['options']['forceinstall'])) {
                                    $message = 'All checks failed on '.$p.'. Possible version misfit. check moodle.org availability.';
                                    if (!empty($_CFG->config['options']['debug'])) {
                                        print_r($plugininfo);
                                    }

                                    if (!empty($_CFG->config['options']['errortrace'])) {
                                        $this->trace($message);
                                    }

                                    if (empty($_CFG->config['options']['ignorefailing'])) {
                                        $this->trace($message);
                                        die();
                                    } else {
                                        continue;
                                    }
                                }
                            }
                        }
                    }

                    if (!empty($downloadurl = $plugininfo->version->downloadurl)) {
                        if (!is_dir($TOOLPATH.'/temp')) {
                            mkdir($TOOLPATH.'/temp', 0777, true);
                        }
                        $componentpath = resolve_location($plugininfo->component, $_CFG->config['core']);;
                        $api->assemble_plugin($plugininfo, $t, dirname($componentpath), $TOOLPATH.'/temp');
                    }
                }
            }

            if (!empty($_CFG->config['options']['copylibloader'])) {
                copy($GENERICROOT.'/local/libloader.php', $t.'/local/libloader.php');
            }

            if (file_exists($t.'/config-tpl.php')) {
                $config = implode('', file($t.'/config-tpl.php'));
                if (!empty($_CFG->config['config'])) {
                    $config = str_replace('%WWWROOT%', $_CFG->config['config']['wwwroot']);
                    unset($_CFG->config['config']['wwwroot']);
                    if (isset($_CFG->config['config']['dirroot'])) {
                        $config = str_replace('%DIRROOT%', $_CFG->config['config']['dirroot']);
                        unset($_CFG->config['config']['dirroot']);
                    } else {
                        $config = str_replace('%DIRROOT%', $t);
                    }
                    $config = str_replace('%DATAROOT%', $_CFG->config['config']['dataroot']);
                    unset($_CFG->config['config']['dataroot']);
                }

                $configbuf = '';
                foreach($_CFG->config['config'] as $key => $value) {
                    $configbuf .= "\$CFG->$key = $value;\n";
                }

                if (!empty($_CFG->config['vmoodle']) && ($_CFG->config['vmoodle'] == 'on')) {
                    $configbuf .= "\n";
                    $configbuf .= '// this fragment will trap the CLI scripts trying to work for a virtual node, and'."\n";
                    $configbuf .= '// needing booting a first elementary configuration based on main config'."\n";
                    $configbuf .= 'if (isset($CLI_VMOODLE_PRECHECK) && $CLI_VMOODLE_PRECHECK == true) {'."\n";
                    $configbuf .= '    $CLI_VMOODLE_PRECHECK = false;'."\n";
                    $configbuf .= '    return;'."\n";
                    $configbuf .= '}'."\n";
                    $configbug .= 'require($CFG->dirroot.\'/local/vmoodle/vconfig.php\');'."\n";
                }

                $config = str_replace('%EXTRASETTINGS%', $configbuf, $config);

                $file = fopen($t.'/config.php', 'w');
                fputs($file, $config);
            }

        }

        return true;
    }

    // Runs after returning up to the calling directory.
    function postprocess($isroot) {
        return false;
    }

    // Runs only once at end of the tool execution.
    function finish() {
        $this->trace();
        $this->trace('Build finished.');
        $this->trace();
    }

    function trace($message = '') {
        echo $message."\n";
        if (!empty($this->trace)) {
            fputs($this->trace, $message."\n");
        }
    }
}


function resolve_location($plugin, $branch) {

    // Extract frankenstyle parts.
    $parts = explode('_', $plugin);
    $type = array_shift($parts);
    $plugin = implode('_', $parts);

    // solve the relative path depending on plugin type.
    $types = array(
        'availability'  => '/availability/condition',
        'atto'         => '/lib/editor/atto/plugins',
        'qtype'         => '/question/type',
        'mod'           => '/mod',
        'auth'          => '/auth',
        'calendartype'  => '/calendar/type',
        'enrol'         => '/enrol',
        'message'       => '/message/output',
        'block'         => '/blocks',
        'filter'        => '/filter',
        'editor'        => '/lib/editor',
        'format'        => '/course/format',
        'profilefield'  => '/user/profile/field',
        'report'        => '/report',
        'coursereport'  => '/course/report', // Must be after system reports.
        'gradeexport'   => '/grade/export',
        'gradeimport'   => '/grade/import',
        'gradereport'   => '/grade/report',
        'gradingform'   => '/grade/grading/form',
        'mnetservice'   => '/mnet/service',
        'webservice'    => '/webservice',
        'repository'    => '/repository',
        'portfolio'     => '/portfolio',
        'qbehaviour'    => '/question/behaviour',
        'qformat'       => '/question/format',
        'plagiarism'    => '/plagiarism',
        'tool'          => '/admin/tool',
        'cachestore'    => '/cache/stores',
        'cachelock'     => '/cache/locks',
        'local'         => '/local',
        'assignsubmission'  => '/mod/assign/submission',
        'assignfeedback'    => '/mod/assign/feedback',
        'customlabeltype'   => '/mod/customlabel/type',
        'quizaccess'        => '/mod/quiz/accessrule',
        'theme'        => '/theme',
        'tinymce'        => '/lib/editor/tinymce/plugins',
    );

    if ($branch <= 27) {
        $types['vmoodleadminset'] = '/blocks/vmoodle/plugins';
    } else {
        $types['vmoodleadminset'] = '/local/vmoodle/plugins';
    }

    if (!array_key_exists($type, $types)) {
        return null;
    }

    return $types[$type].'/'.$plugin;
}

