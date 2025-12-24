<?php

define('DEBUG_NO', 0);
define('DEBUG_NORMAL', 4);
define('DEBUG_ERROR', 5);
define('DEBUG_DEVELOPER', 10);

global $CFG;
if (is_null($CFG)) {
    $CFG = new StdClass;
    $CFG->debug = DEBUG_DEVELOPER;
}

function moodle_update_debugging($msg, $level) {
    global $CFG;

    if ($level >= $CFG->debug) {
        echo 'Moodle-Update Error: '.$msg."\n";
    }
}