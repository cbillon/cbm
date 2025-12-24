<?php

namespace tool;

require_once('moodle-update/api.php');
require_once('moodle-update/info.php');
require_once('moodle-update/remote_info.php');
require_once('moodle-update/curl.class.php');
require_once('moodle-update/zip_archive.class.php');
require_once('moodle-update/text.class.php');

use core\update\api;
use zip_archive;
use file_archive;
use curl;

define('ANY_VERSION', 'any');

class moodle_plugins_remote {

    protected static $api;

    public function init() {
        self::$api = api::client();
    }

    function get_latest_version($component, $version = ANY_VERSION, $branch) {
        return self::$api->find_plugin($component, $version, $branch);
    }

    function assemble_plugin($plugininfo, $target, $componentpath, $templocation) {

        $tempzip = $templocation.'/zip/';
        $fullcomponentpath = $target.'/'.$componentpath;

        if (!is_dir($tempzip)) {
            mkdir($tempzip, 0777, true);
        }

        $c = new curl();

        $zipfile = $tempzip.'/'.$plugininfo->component.'.zip';
        $options = array('filepath' => $zipfile,
                         'timeout' => 60,
                         'followlocation' => true,
                         'maxredirs' => 3);
        $zipurl = $plugininfo->version->downloadurl;
        $result = $c->download_one($zipurl, null, $options);

        if ($result !== true) {
            echo 'cURL: Error '.$c->get_errno().':'.$result.' when calling '.$zipurl."\n";
            return false;
        }

        echo "Extracting component\n";
        echo "Origin : $zipfile\n";
        echo "In : $fullcomponentpath\n";
        $this->extract_to_pathname($zipfile, $fullcomponentpath);

    }

    /**
     * Unzip file to given file path (real OS filesystem), existing files are overwritten.
     *
     * @todo MDL-31048 localise messages
     * @param string|stored_file $archivefile full pathname of zip file or stored_file instance
     * @param string $pathname target directory
     * @param array $onlyfiles only extract files present in the array. The path to files MUST NOT
     *              start with a /. Example: array('myfile.txt', 'directory/anotherfile.txt')
     * @param file_progress $progress Progress indicator callback or null if not required
     * @return bool|array list of processed files; false if error
     */
    public function extract_to_pathname($archivefile, $pathname, array $onlyfiles = null) {
        global $CFG;

        $processed = array();

        $pathname = rtrim($pathname, '/');
        if (!is_readable($archivefile)) {
            return false;
        }
        $ziparch = new zip_archive();
        if (!$ziparch->open($archivefile, file_archive::OPEN)) {
            return false;
        }

        // Get the number of files (approx).
        $approxmax = $ziparch->estimated_count();

        foreach ($ziparch as $info) {

            $size = $info->size;
            $name = $info->pathname;

            if ($name === '' or array_key_exists($name, $processed)) {
                // Probably filename collisions caused by filename cleaning/conversion.
                continue;
            } else if (is_array($onlyfiles) && !in_array($name, $onlyfiles)) {
                // Skipping files which are not in the list.
                continue;
            }

            if ($info->is_directory) {
                $newdir = "$pathname/$name";
                // directory
                if (is_file($newdir) && !unlink($newdir)) {
                    $processed[$name] = 'Can not create directory, file already exists'; // TODO: localise
                    continue;
                }
                if (is_dir($newdir)) {
                    //dir already there
                    $processed[$name] = true;
                } else {
                    if (mkdir($newdir, 0777, true)) {
                        $processed[$name] = true;
                    } else {
                        $processed[$name] = 'Can not create directory'; // TODO: localise
                    }
                }
                continue;
            }

            $parts = explode('/', trim($name, '/'));
            $filename = array_pop($parts);
            $newdir = rtrim($pathname.'/'.implode('/', $parts), '/');

            if (!is_dir($newdir)) {
                if (!mkdir($newdir, 0777, true)) {
                    $processed[$name] = 'Can not create directory'; // TODO: localise
                    continue;
                }
            }

            $newfile = "$newdir/$filename";
            if (!$fp = fopen($newfile, 'wb')) {
                $processed[$name] = 'Can not write target file'; // TODO: localise
                continue;
            }
            if (!$fz = $ziparch->get_stream($info->index)) {
                $processed[$name] = 'Can not read file from zip archive'; // TODO: localise
                fclose($fp);
                continue;
            }

            while (!feof($fz)) {
                $content = fread($fz, 262143);
                fwrite($fp, $content);
            }
            fclose($fz);
            fclose($fp);
            if (filesize($newfile) !== $size) {
                $processed[$name] = 'Unknown error during zip extraction'; // TODO: localise
                // something went wrong :-(
                @unlink($newfile);
                continue;
            }
            $processed[$name] = true;
        }
        $ziparch->close();
        return $processed;
    }
}