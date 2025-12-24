<?php

/**
 * These are general functions several tools use, as a super class for all tools.
 *
 */

namespace tool;

class tool_base {

    protected $rmcomand;

    function __construct() {
        global $_CFG;

        if (empty($_CFG)) {
            die("tool construct : No Moodle CFG found. Cannot determine OS type.\n");
        }

        // Set file and dir rm command.
        if ($_CFG->os == 'Windows') {
            $this->rmcommand = 'del /S /Q ';
        } else {
            $this->rmcommand = 'rm -rf ';
        }
    }

    /**
     * Some tools may have to launch other commands before processing their own, starting from
     * the command tool directory.
     */
    public function pre_recurse() {
        return true;
    }

    public function delete_dir($path) {
        global $_CFG;

        // Delete in standard pro location
        if (!is_dir($path)) {
            echo "Delete Dir : Unkown location $path\n";
        }

        $delcommand = $this->rmcommand.$path;
        $deldircommand = false;
        if ($_CFG->os == 'Windows') {
            $targetdir = str_replace('/', '\\', $path);
            $delcommand = $this->rmcommand.$targetdir;
            $deldircommand = "for /f %f in ('dir /ad /b {$targetdir}\\') do rd /s /q {$targetdir}\\%f";
            $delrootcommand = "rd /s /q {$targetdir}";
        } else {
            $delcommand = $this->rmcommand.$path;
        }
        echo "   Removing ".basename($path)." ...\n";
        exec($delcommand);

        // Remove dirs recursively on Windows.
        if (!empty($deldircommand)) {
            exec($deldircommand);
            exec($delrootcommand);
        }
    }

    public function format_cygwin_command($cmd) {
        $cmd = str_replace("\\", '/', $cmd);
        $cmd = str_replace("C:/", '/cygdrive/c/', $cmd);

        return $cmd;
    }
}