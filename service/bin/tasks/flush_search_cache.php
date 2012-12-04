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

define('ROOTDIR', __DIR__);

# Initiate bootstrapper
$bootstrap = new Bootstrap(APPLICATION_ENV);

# Initiate logger
$logger = new Logger('FlushSearchCache');
$logger->pushHandler(new StreamHandler("php://stdout", Logger::DEBUG));

$cacheRefRepo = $bootstrap->dm->getRepository('Document\CacheRef');

$cacheRefs = $bootstrap->dm->createQueryBuilder('Document\CacheRef')
        ->select('_id', 'cacheFile')->hydrate(false)->getQuery()->execute();
echo 'Total cache references - ' . count($cacheRefs) . "\n";

foreach ($cacheRefs as $cacheRef) {
    $cacheRefRepo->delete($cacheRef['_id']->{'$id'});
    @unlink($cacheRef['cacheFile']);
}

echo "Done\n";
$client->runTasks();
