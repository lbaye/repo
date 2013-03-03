#!/usr/bin/env php
<?php

if (count($argv) < 2) {
    die("Usages: <script>.php <ENV> <USER_ID>\n");
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
$logger = new Logger('CheckUser');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

$userRepo = $bootstrap->dm->getRepository('Document\User');

# Retrieve all users
$users = $bootstrap->dm->createQueryBuilder('Document\User')
        ->select('facebookId', 'email')
        ->hydrate(false)->getQuery()->execute();

$thingsToRemove = array(
    'Event' => 'owner',
    'Meetup' => 'owner',
    'Message' => 'sender',
    'Photo' => 'owner',
    'Place' => 'owner',
    'Plan' => 'owner',
    'UserActivity' => 'owner',
    'User' => '_id'
);

$duplicateUsers = array();

foreach ($users as $user) {
    $fbId = $user['facebookId'];

    if (!empty($fbId)) {
        $fbUsers = $bootstrap->dm->createQueryBuilder('Document\User')
                ->select('_id', 'firstName', 'lastLogin', 'facebookId')
                ->field('facebookId')->equals($user['facebookId'])
                ->hydrate(false)->getQuery()->execute();

        if (count($fbUsers) > 1) {
            foreach ($fbUsers as $fbUser) {
                $duplicateUsers[] = $fbUser['_id'];
            }
        }
    }
}

$duplicateUsers = array_unique($duplicateUsers);

if (empty($duplicateUsers)) {
    echo "No duplicate user found\n";
} else {
    echo count($duplicateUsers) . " duplicate users found.";
}


