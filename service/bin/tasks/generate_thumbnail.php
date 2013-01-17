#!/usr/bin/env php
<?php

if (count($argv) < 2) {
    die("Usages: <script>.php <ENV>");
}

require_once __DIR__ . '/../../app/autoload.php';
require_once __DIR__ . '/../../app/AppBootstrap.php';
require_once __DIR__ . '/../../app/GearmanKernel.php';

use Monolog\Logger,
    Monolog\Handler\StreamHandler,
    \Repository\UserRepo;

defined('APPLICATION_ENV')
|| define('APPLICATION_ENV', (isset($argv[1]) ? $argv[1] : 'dev'));

define('ROOTDIR', __DIR__ . '/../../web/');

# Initiate bootstrapper
$bootstrap = new Bootstrap(APPLICATION_ENV);

# Initiate logger
$logger = new Logger('GenerateThumbnail');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

$userRepo = $bootstrap->dm->getRepository('Document\User');

$users = $bootstrap->dm->createQueryBuilder('Document\User')->hydrate(false)->getQuery()->execute();

# Iterate through each user
\Helper\Image::makeThumbImageForAvatars();

$logger->info('Generated thumbs for all images.');
$client->runTasks();
