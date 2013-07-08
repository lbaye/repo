#!/usr/bin/env php
<?php

require_once __DIR__ . '/../../app/autoload.php';
require_once __DIR__ . '/../../app/AppBootstrap.php';
require_once __DIR__ . '/../../app/GearmanKernel.php';

use Monolog\Logger,
Monolog\Handler\StreamHandler,
\Repository\UserRepo;

defined('APPLICATION_ENV')
|| define('APPLICATION_ENV', (isset($argv[1]) ? $argv[1] : 'dev'));

define('ROOTDIR', __DIR__);

if (count($argv) < 2) die("<script> <ENV> <USER_ID>\n");

# Initiate bootstrapper
$bootstrap = new Bootstrap(APPLICATION_ENV);

# Initiate logger
$logger = new Logger('UpdateAddressForAllLocations');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

# Configure gearman client
$client = new GearmanClient();
$client->addServer('127.0.0.1');
$client->setCompleteCallback(function($task) {
        echo $task->jobHandle() . " = " . $task->data(), PHP_EOL;
        flush();
    });

$client->addTaskBackground('proximity_alert', json_encode(array(
            'user_id' => $argv[2],
            'timestamp' => time(),
            'validity' => 7200, // 2 hours
        )));

$client->runTasks();
