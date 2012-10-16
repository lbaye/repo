#!/usr/bin/env php
<?php

if (count($argv) < 2) {
    die("Usages: <script>.php <ENV> <*FB_ID> <*FB_AUTH_TOKEN>");
}

require_once __DIR__ . '/../../app/autoload.php';
require_once __DIR__ . '/../../app/AppBootstrap.php';
require_once __DIR__ . '/../../app/GearmanKernel.php';

use Monolog\Logger,
    Monolog\Handler\StreamHandler,
    \Repository\UserRepo;

defined('APPLICATION_ENV')
|| define('APPLICATION_ENV', (isset($argv[1]) ? $argv[1] : 'dev'));

define('ROOTDIR', __DIR__);

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

if (count($argv) > 3) {
    $userId = $argv[1];
    $fbId = $argv[2];
    $fbAuthToken = $argv[3];
} else {
    $userId = $argv[0];
    $fbId = $argv[1];
    $fbAuthToken = $argv[2];
}

$client->addTaskBackground(
    'fetch_facebook_location',
    json_encode(array('userId' => $userId, 'facebookId' => $fbId, 'facebookAuthToken' => $fbAuthToken))
);

$client->runTasks();
