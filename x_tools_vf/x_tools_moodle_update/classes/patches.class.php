<?php

namespace tool;

use DirectoryIterator;

class patches {

    /** @var Root of the assembled code */
    protected $coderoot;

    /** @var Root of the core reference code */
    protected $coreroot;

    /** @var the calling code assembler instance. */
    protected $codeassembler;

    /** @var A dynamic path that is changed while examinating patch (or customscripts) content hierarchy. */
    protected $currentpath;

    /** @var A dynamic path that is changed while examinating patch that points patch sources in component being processed. */
    protected $currentcomponentdir;

    public function __construct($coderoot, $coreroot, $codeassembler) {
        $this->coderoot = $coderoot;
        $this->coreroot = $coreroot;
        $this->codeassembler = $codeassembler;
        $this->currentpath = '';
        $this->currentcomponentdir = '';
    }

    /**
     * Fetches core file and calculate a patch integration in it. Outputs the patched
     * file in the target location. This is the root point of action.
     */
    public function apply_patchs($isroot = true, $componentdir = '') {

        if ($isroot) {

            if (!is_dir($this->coreroot.$componentdir)) {
                $assembler->trace("\tERROR: Cannot patch here. Original path {$COREROOT}{$corepath} does not exist.");
                return;
            }

            $this->componentdir = $this->fix_slashed_path($componentdir);

            // Get relative entries for known patches.
            $entries = new DirectoryIterator($this->coderoot.$componentdir.'/__patch');
            $this->currentpath = '/';
        } else {
            $entries = new DirectoryIterator($this->coderoot.$componentdir.'/__patch'.$this->currentpath);
        }

        if ($entries) {
            foreach ($entries as $entry) {

                if ($entry->idDot()) {
                    continue;
                }

                if ($entry->isDir()) {
                    // Recurse in subdirectories.
                    $entrydir = $entry->getBasename();
                    $this->currentpath = $this->currentpath.'/'.$entrydir;
                    $this->apply_patchs();
                    $this->currentpath = dirname($this->currentpath);
                } else {
                    if ($entry->getExtension() == '.bak') {
                        // Ignore backups.
                        continue;
                    }
                    $this->apply_patch_from_file($entry);
                }
            }
        } else {
            $assembler->trace("\tNo patch entries in $componentpatchpath.");
        }
    }

    /**
     * Given one patch file. Applies it.
     */
    public function apply_patchs_from_file($entry) {

        // This is a true patched file.
        // First check it hasn't be already patched.

        $entryfile = $entry->getBasename();

        // Original file in assembled codebase.
        $originalfile = $this->coderoot.$this->currentpath.'/'.$entryfile;

        if (!file_exists($originalfile)) {
            $assembler->trace('\tERROR: Cannot patch. Original file does not exist in target codebase. this is possible a core version mismatch.');
            return;
        }

        $assembler->trace("Patching in $originalfile");

        $originalcode = implode("\n", @file($originalfile));

        $patchsource = $this->coderoot.'/'.$this->currentcomponentdir.'/__patch'.$this->currentpath.'/'.$entryfile;
        $patchcode = implode("\n", file($patchsource));

        // Now we need see if this patchsource has been already be applied.
        // So find one patch in the patch source and try to locate it in originalcode.
        // PATCHS must strictly be marked as PATCH+ with a label telling what it serves.
        // So we can check if the patch marker (should be unique in a single source code) is here.
        // Note that patches can come from several patchsources in the same file. We just expect
        // that there are no line or segment collision.

        if (!preg_match('/PATCH\+.*$/i', $patchcode, $matches)) {
            // Weird, this patch source contains no patchs ? or ?
            $assembler->trace("\tERROR: Patch source seems having no patchs.");
            return;
        }
        if (preg_match('/'.$matches[0].'/', $originalcode)) {
            // We found it !! the patch is here !!
            if (empty($_CFG->config['options']['overpatch'])) {
                $assembler->trace("\tWARNING: Patch Target already patched. Skipping the file.");
                return;
            }

            $assembler->trace("\tPatching in {$originalfile}");

            $res = $this->process_patchs_in_file($patchedcontent, $newpatches);

            $assembler->trace("\tSaving back .{$res->patchcount} patches.");

            // Make a backup.
            if (!empty($_CFG->config['options']['generatebackup'])) {
                $backupfile = $originalfile.'.bak';
                copy($originalfile, $backupfile);
            }

            $OUT = fopen($originalfile, 'w');
            fputs($OUT, $res->output);
            $assembler->trace("\tPatch file rewritten.");
            fclose($OUT);
        }
    }

    public function apply_customscripts($coderoot, $corepath, $componentscriptpath, &$assembler) {

        $entries = glob($coderoot.$componentscriptpath.'/*');

        if (!is_dir($coderoot.$corepath) && is_dir($coderoot.$componentscriptpath)) {
            // Create missing dirs in customscripts.
            $assembler->trace("\tAdding scripting dir $coderoot.$corepath");
            mkdir($coderoot.$corepath, 0775);
        }

        if ($entries) {
            foreach ($entries as $entry) {
                if (preg_match('/\.$/', $entry)) {
                    continue;
                }
                if (is_dir($entry)) {
                    $entrydir = basename($entry);
                    $this->apply_customscripts($coderoot, $corepath.'/'.$entrydir, $componentscriptpath.'/'.$entrydir, $assembler);
                } else {
                    // This is a true customscript file.
                    // First check it hasn't be already patched
                    $entryfile = basename($entry);
                    if (file_exists($coderoot.$corepath.$entryfile)) {
                        $assembler->trace("\tWARNING: Customscript Target $entry already installed. Cannot overscript automatically. Needs merge.");
                    } else {
                        $assembler->trace("\tCustomscripting {$coderoot}{$corepath}/{$entryfile}");
                        $cmd = "copy \"$entry\" \"{$coderoot}{$corepath}/{$entryfile}\"";
                        $cmd = str_replace('/', '\\', $cmd); // Windowify.
                        exec($cmd, $output, $return);
                    }
                }
            }
        } else {
            $assembler->trace("\tNo customscript entries");
        }
    }

    /**
     * analyses a single file and scan for patches in
     */
    function processpatchsinfile(&$input, &$patchfile, &$assembler) {
        global $CFG;

        //pattern is :
        //matches[1] : prescanaround
        //matches[2] : complete patch with markers
        //matches[3] : postscanaround

        $offset = 0;

        $res = new StdClass;
        $res->output = $input;
        $res->patchcount = 0;
        $res->notfoundcount = 0;
        $res->toomanyfoundcount = 0;

        while ($patch = preg_match("/({$_CFG->scanaroundupperpattern})({$_CFG->patchstartpattern}.*?{$_CFG->patchendpattern})({$_CFG->scanaroundlowerpattern})/s", $patchfile, $matches, PREG_OFFSET_CAPTURE, $offset)){

            $offset = $matches[2][1] + strlen($matches[2][0]);
            $prepattern = $matches[1][0];
            $patchlocation = $matches[0][1] + strlen($prepattern);
            $patchline = substr_count(substr($code, 0, $patchlocation), "\n"); // Counts number of lines before patch.
            $quotedprepattern = preg_quote($prepattern);
            $quotedprepattern = str_replace("/", "\\/", $quotedprepattern);
            $patchcontent = $matches[2][0];
            $postpattern = $matches[3][0];
            $quotedpostpattern = preg_quote($postpattern);
            $quotedpostpattern = str_replace("/", "\\/", $quotedpostpattern);

            // Any number of blank lines before patch or after patch should be insignificant.
            $quotedprepattern = preg_replace("/(\\s*\\n)*$/", '', $quotedprepattern); // Trim left prepattern.
            $quotedpostpattern = preg_replace("/^(\\s*\\n)*/", '', $quotedpostpattern); // Trim right prepattern.

            $quotedprepattern = preg_replace("/\\n/", "\\\\n", $quotedprepattern); // Convert endline into preg endline escapes.
            $quotedpostpattern = preg_replace("/\\n/", "\\\\n", $quotedpostpattern);

            $destpattern = '/'.$quotedprepattern.'(.*?)'.$quotedpostpattern.'/su';

            // Test match.
            $assembler->trace("PATTERN: prematch : ".preg_match("/$quotedprepattern/su", $destcode));
            $assembler->trace("PATTERN: prematch pattern : ".$quotedprepattern);
            $assembler->trace("PATTERN: postmatch : ".preg_match("/$quotedpostpattern/su", $destcode));

            $quotedpatch = preg_quote($patchcontent);
            $quotedpatch = str_replace('/', "\\/", $quotedpatch);
            if (preg_match('/'.$quotedpatch.'/', $input)) {
                $assembler->trace("PATTERN: patch already found (or it looks like it is!), so skipping this one.");
                continue;
            }

            // We search in destcode where the patch could be inserted.
            $locations = preg_match_all($destpattern, $output, $matches, PREG_PATTERN_ORDER);
            if (empty($locations)) {
                $assembler->trace("¨PATTERN ERROR: no location found in {$filepath}");
                $assembler->trace("\tOriginal location : {$filepath} §{$patchline}");
                $res->notfoundcount++;
            } else if (count($locations) > 1) {
                $assembler->trace("PATTERN ERROR: too many locations in cdest file: {$filepath}");
                $assembler->trace("\tOriginal location : {$filepath} §{$patchline}");
                $res->toomanyfoundcount++;
            } else {
                // We have a single location !!
                $assembler->trace("PATTERN: Patch found : Original location : {$filepath} §{$patchline}");
                $assembler->trace("\n*******\nPATCH\n*******\n$patchcontent");
                $res->output = preg_replace($destpattern, "{$prepattern}{$patchcontent}{$postpattern}", $output);
                $res->patchcount++;
            }
        }

        return $res;
    }

    /**
     * A Utlity that ensures a path has leading slash
     */
    protected function fix_slashed_path($path) {
        if (strpos($path, '/') === 0) {
            return $path;
        }
        return '/'.$path;
    }

}