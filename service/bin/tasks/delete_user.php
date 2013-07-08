#!/usr/bin/env php
<?php

if (count($argv) < 3) {
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
$logger = new Logger('DeleteUser');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

$userRepo = $bootstrap->dm->getRepository('Document\User');
$userId = $argv[2];

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

foreach ($thingsToRemove as $docName => $field) {
    $logger->debug('Removing ' . $docName . ' for id - ' . $userId);
    try {
        $q = $bootstrap->dm->createQueryBuilder(sprintf('Document\%s', $docName))
            ->field($field)->equals($userId)->remove()->getQuery()->execute();
        $logger->debug("Removed " . $docName . ' for id - ' . $userId);
    } catch (\Exception $e) {
        $logger->err("Failed to remove " . $docName . ' for id - ' . $userId);
    }
}

$logger->info('Removed user with id - ' . $userId);