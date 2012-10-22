#!/usr/bin/env php
<?php

if (count($argv) < 2) {
    die("Usages: <script>.php <ENV> <*UID> <*FB_ID> <*FB_AUTH_TOKEN>");
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
$logger = new Logger('FetchFbUserCheckins');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

# Configure gearman client
$client = new GearmanClient();
$client->addServer('127.0.0.1');
$client->setCompleteCallback(function($task) {
    echo $task->jobHandle() . " = " . $task->data(), PHP_EOL;
    flush();
});

if (count($argv) == 5) {
    $userId = $argv[2];
    $fbId = $argv[3];
    $fbAuthToken = $argv[4];
} else if (count($argv) == 4) {
    $userId = $argv[1];
    $fbId = $argv[2];
    $fbAuthToken = $argv[3];
} else if (count($argv) == 3) {
    $userId = $argv[2];
} else {
    die("Invalid arguments");
}

if (!isset($fbId)) {
    $repo = $bootstrap->dm->getRepository('Document\User');
    $user = $repo->find($userId);

    if (!$user)
        die("No user found for id - $userId" . PHP_EOL);
    
    $repo->refresh($user);
    $fbId = $user->getFacebookId();

    if (empty($fbId))
        die("No facebook reference found");

    $fbAuthToken = $user->getFacebookAuthToken();
}

$client->addTaskBackground(
    'fetch_facebook_location',
    json_encode(array('userId' => $userId, 'facebookId' => $fbId, 'facebookAuthToken' => $fbAuthToken))
);

$logger->info("Request sent for fetching facebook checkins");

$client->runTasks();
