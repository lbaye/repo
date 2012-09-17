#!/usr/bin/env php
<?php

$client= new GearmanClient();
$client->addServer('127.0.0.1');
$client->setCompleteCallback(function($task){
    echo $task->jobHandle() . " = " . $task->data(), PHP_EOL;
    flush();
});

$task = $client->addTask("fetch_external_location", json_encode(array()));
$client->runTasks();