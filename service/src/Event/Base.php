<?php

namespace Event;

use Symfony\Component\Yaml\Parser;

abstract class Base
{
    /**
     * @var array
     */
    protected $conf;

    /**
     * @var array
     */
    protected $serviceConf;

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
        $this->serviceConf = $this->_getServiceConfig();

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

    private static function _getServiceConfig()
    {
        $yaml = new Parser();
        return $yaml->parse(file_get_contents(ROOTDIR .'/../app/config/services.yml'));
    }

    abstract protected function setFunction();
    abstract public function run(\GearmanJob $job);
}