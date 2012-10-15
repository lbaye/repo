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
$qb = $bootstrap->dm->createQueryBuilder('Document\User')
        ->eagerCursor(false);
$query = $qb->getQuery();
$cursor = $query->execute();

$items_per_page = 40;
$total_items = count($cursor);
$num_of_iterations = ceil($total_items / $items_per_page);

echo "Total Users - $total_items\n";
echo "Per page - $items_per_page\n";
echo "Number of iterations - $num_of_iterations\n";

for ($i = 1; $i <= $total_items; $i += $items_per_page) {
    $users = $bootstrap->dm->createQueryBuilder('Document\User')
            ->hydrate(false)
            ->limit($items_per_page)
            ->skip($i - 1)
            ->getQuery()
            ->execute();

    foreach ($users as $user) {
        $location = $user['currentLocation'];
        echo "---------------------------------------------------\n";
        echo "             {$user['firstName']} # {$user['_id']->{'$id'}}\n";
        echo "---------------------------------------------------\n";

        if (!empty($location)) {
            $client->addTask('update_last_seen_address', json_encode(array('user_id' => $user['_id']->{'$id'})));
        }
    }

}

$client->runTasks();
