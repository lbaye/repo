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

    public function __construct($conf, $services)
    {
        $this->conf = $conf;
        $this->services = $services;

        $this->setFunction();
    }

    public function getFunction()
    {
        return $this->function;
    }

    abstract protected function setFunction();
    abstract public function run(\GearmanJob $job);
}