<?php

namespace Event;

abstract class Base
{
    /**
     * @var array
     */
    protected $conf;

    /**
     * @var array
     */
    protected $services;

    /**
     * @var string
     */
    protected $function;

    /**
     * @var \GearmanClient
     */
    protected $gearmanClient;

    public function __construct($conf, $services)
    {
        $this->conf = $conf;
        $this->services = $services;

        $this->setFunction();
        $this->setupGearman();
    }

    public function getFunction()
    {
        return $this->function;
    }

    private function setupGearman()
    {
        $this->gearmanClient = new \GearmanClient();
        $this->gearmanClient->addServer($this->conf['gearman']['host'], $this->conf['gearman']['port']);
    }

    protected function addTaskBackground($eventName, $data)
    {
        $this->gearmanClient->addTaskBackground($eventName, $data);
    }

    protected function addTask($eventName, $data)
    {
        $this->gearmanClient->addTask($eventName, $data);
    }

    protected function runTasks()
    {
        $this->gearmanClient->runTasks();
    }

    abstract protected function setFunction();
    abstract public function run(\GearmanJob $job);
}