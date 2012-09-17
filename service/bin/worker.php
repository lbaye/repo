#!/usr/bin/env php
<?php

require_once __DIR__ . '/../app/autoload.php';
require_once __DIR__ . '/../app/AppBootstrap.php';
require_once __DIR__ . '/../app/GearmanKernel.php';

defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (isset($argv[1]) ? $argv[1] : 'dev'));

define('ROOTDIR', __DIR__);

$bootstrap = new Bootstrap(APPLICATION_ENV);

$kernel = new GearmanKernel($bootstrap->dm, $bootstrap->conf);
$kernel->handle();