#!/usr/bin/env php
<?php

require_once __DIR__ . '/../app/autoload.php';
require_once __DIR__ . '/../app/AppBootstrap.php';
require_once __DIR__ . '/../app/GearmanKernel.php';

use Monolog\Logger,
    Monolog\Handler\StreamHandler;

defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (isset($argv[1]) ? $argv[1] : 'dev'));

define('ROOTDIR', __DIR__);

# Initiate bootstrapper
$bootstrap = new Bootstrap(APPLICATION_ENV);

# Initiate logger
$logger = new Logger('Worker');
$logger->pushHandler(new StreamHandler('php://stdout', Logger::DEBUG));

# Initiate system kernel
$eventType = null;

if (count($argv) > 2) {
    $eventType = $argv[2];
}

$kernel = new GearmanKernel($bootstrap->dm, $bootstrap->conf, $logger, $eventType);

$kernel->handle();