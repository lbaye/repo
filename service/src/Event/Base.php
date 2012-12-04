<?php

namespace Event;

use Symfony\Component\Yaml\Parser;

abstract class Base {
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

    protected $logger;

    /**
     * @var \GearmanClient
     */
    protected $gearmanClient;

    public function __construct($conf, $services) {
        $this->info("Constructing Event::Base");
        $this->debug("Constructing Event::Base with $conf and $services");

        $this->conf = $conf;
        $this->services = $services;
        $this->serviceConf = $this->_getServiceConfig();

        $this->setFunction();
        $this->setupGearman();
    }

    public function getFunction() {
        return $this->function;
    }

    private function setupGearman() {
        $this->info("Setting up gearman client");
        $this->gearmanClient = new \GearmanClient();
        $this->gearmanClient->addServer($this->conf['gearman']['host'], $this->conf['gearman']['port']);
    }

    protected function addTaskBackground($eventName, $data) {
        $this->gearmanClient->addTaskBackground($eventName, $data);
    }

    protected function addTask($eventName, $data) {
        $this->gearmanClient->addTask($eventName, $data);
    }

    protected function runTasks() {
        $this->gearmanClient->runTasks();
    }

    private static function _getServiceConfig() {
        $yaml = new Parser();
        return $yaml->parse(file_get_contents(ROOTDIR . '/../app/config/services.yml'));
    }

    protected function isFreshRequest($workload) {
        // 0 means always valid
        if (empty($workload->validity)) return true;

        return ((time() - intval($workload->timestamp)) < intval($workload->validity));
    }

    abstract protected function setFunction();

    abstract public function run(\GearmanJob $job);

    public function setLogger($logger) {
        $this->logger = $logger;
    }

    public function getLogger() {
        return $this->logger;
    }

    public function isLoggerEnabled() {
        return !empty($this->logger);
    }

    private function log($type, $msg) {
        if ($this->isLoggerEnabled()) {
            $this->logger->{$type}($msg);
        }
    }

    public function debug($msg) {
        $this->log('debug', $msg);
    }

    public function info($msg) {
        $this->log('info', $msg);
    }

    public function warn($msg) {
        $this->log('warn', $msg);
    }

    public function error($msg) {
        $this->log('err', $msg);
    }

    public function notice($msg) {
        $this->log('notice', $msg);
    }

    public function checkMemoryBefore() {
        $this->debug("Memory usage before: " . (memory_get_usage() / 1024) . " KB");
    }

    public function checkMemoryAfter() {
        $this->debug("Memory usage after: " . (memory_get_usage() / 1024) . " KB");
    }

    public function logJob($name, $job) {
        $this->info("Executing Event::$name with job - {$job->unique()}");
    }

    protected function _getAddress($current_location) {
        $this->debug('Get address from reverse geo location service.');
        $reverseGeo = new \Service\Geolocation\Reverse(
            $this->getLogger(),
            $this->serviceConf['googlePlace']['apiKey'],
            $this->services['dm']);

        $address = $reverseGeo->getAddress($current_location);
        $this->debug('Found reversed geo location - ' .
            "$address ({$current_location['lat']}" . ', ' .
            "{$current_location['lng']})");

        return $address;
    }

}