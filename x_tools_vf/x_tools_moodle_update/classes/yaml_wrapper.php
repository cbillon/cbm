<?php

namespace tool;

require_once('yaml-master/Exception/ExceptionInterface.php');
require_once('yaml-master/Exception/RuntimeException.php');
require_once('yaml-master/Exception/ParseException.php');
require_once('yaml-master/Exception/DumpException.php');
require_once('yaml-master/Yaml.php');
require_once('yaml-master/Parser.php');
require_once('yaml-master/Inline.php');
require_once('yaml-master/Escaper.php');
require_once('yaml-master/Unescaper.php');
require_once('yaml-master/Dumper.php');

use \Symfony\Component\Yaml\Yaml;

class yaml_parser {

    static function parse($input) {
        return Yaml::parse($input);
    }
}