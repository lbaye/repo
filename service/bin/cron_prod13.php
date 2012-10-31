#!/usr/bin/env php
<?php

echo "Initiating cron task" . PHP_EOL;

$client= new GearmanClient();
$client->addServer('10.234.125.185', 4730);
$client->setCompleteCallback(function($task){
    echo $task->jobHandle() . " = " . $task->data(), PHP_EOL;
    flush();
});
echo "Gearman connected." . PHP_EOL;

$task = $client->addTaskBackground("fetch_external_location", json_encode(array()));
$client->runTasks();

echo "Run task" . PHP_EOL;