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

# Retrieve all users and update their current location
$repo = $bootstrap->dm->getRepository('Document\User');
$logger->debug('Looking user by - ' . $argv[2]);
$user = $repo->find($argv[2]);

var_dump($user->getName());

$client->addTaskBackground('update_last_seen_address',
                           json_encode(array('user_id' => $user->getId())));

$client->runTasks();
