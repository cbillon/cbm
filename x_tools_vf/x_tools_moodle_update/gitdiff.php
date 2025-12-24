<?php
date_default_timezone_set('UTC');
$date = date("l dS of F Y h:i:s A", time());
echo "production tool : diff\n$date\n";
echo "Makes a diff on screen or in a .yml file between an integrated moodle and a core version\n
By Valery Fremaux 2016 for Moodle (valery.fremaux@gmail.com)
---------------------------\n";

// A global tool must assume acting in current directory.

if (!defined('MOODLE_INTERNAL')) {
    define('MOODLE_INTERNAL', 1);
}

class tool {

    // Runs only once at start of the tool.
    function init() {
        global $rsynccoreroot;
        global $_CFG;

    }

    // Runs as soon as digging down into the directory.
    // No care it is root as we look for explicit codeincrement extra attribute.
    function preprocess($isroot = false) {
        global $PATH;
        global $_CFG;
        global $TOOLPATH;

        $handledversions = array(27, 28, 29, 30, 31);

        echo "working in ".getcwd()."\n";
        $_CFG->moodleroot = 'C:/wwwroot64';

        $_CFG->pluginpaths = array(
            'availability'  => '/availability/condition',
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
            /* 'customlabeltype'   => '/mod/customlabel/type', */
            'quizaccess'        => '/mod/quiz/accessrule');

        return true;
    }

    // Runs after returning up to the calling directory.
    function postprocess($isroot) {
        global $_CFG;

        // Extract the core version.

        if (!preg_match('/\d\d/', $_CFG->command_params->root, $matches)) {
            die('No version detected');
        }
        echo "Resolving moodle version to {$matches[0]}\n";
        $_CFG->MOODLE_VERSION = $matches[0];

        $targetmoodle = $_CFG->moodleroot.'/'.$_CFG->command_params->root;
        $coremoodle = $_CFG->moodleroot.'/moodle_'.$_CFG->MOODLE_VERSION.'_core';

        $_CFG->diff = array();

        // Scan plugin types and get the difference.
        foreach($_CFG->pluginpaths as $modtype => $p) {
            echo 'Exploring '.$targetmoodle.$p."\n";
            $core = glob($targetmoodle.$p.'/*', GLOB_ONLYDIR);
            foreach ($core as $c) {
                $bn = basename($c);
                if (!is_dir($coremoodle.$p.'/'.$bn)) {
                    $_CFG->diff[$modtype][] = $modtype.'_'.$bn;
                }
            }
        }
    }

    // Runs only once at end of the tool execution.
    function finish() {
        global $_CFG;
        global $TOOLPATH;

        $indent = '    ';

        if (empty($_CFG->command_params->output)) {
            $_CFG->command_params->output = 'yml';
        }

        if ($_CFG->command_params->output == 'yml') {

            if (empty($_CFG->command_params->outputfile)) {
                $outputfile = $TOOLPATH.'/receipe_'.$_CFG->command_params->root.'.yml';
            } else {
                $outputfile = $_CFG->command_params->outputfile;
            }

            echo "\nProducing yml receipe in $outputfile\n";

            if ($receipe = fopen($outputfile, 'w')) {

                fputs($receipe, '# Generated on '.date('Y-m-d')."\n\n");
                fputs($receipe, "targets:\n\n");
                fputs($receipe, "core:\n{$indent}{$_CFG->MOODLE_VERSION}\n\n");
                fputs($receipe, "override:\n{$indent}{$_CFG->MOODLE_VERSION}\n\n");

                fputs($receipe, "plugins:\n");
                foreach ($_CFG->diff as $typeddiff) {
                    fputs($receipe, "\n");
                    foreach ($typeddiff as $p) {
                        fputs($receipe, "{$indent}- {$p}\n");
                    }
                }
                fputs($receipe, "\n");

                fputs($receipe, "config:\n\n");

                fputs($receipe, "vmoodle: off\n\n");

                fclose($receipe);
            } else {
                die('Error writing output file');
            }

            echo "\nyml finished\n";
        }
    }
}