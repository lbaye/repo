<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;

class Base extends DocumentRepository
{
    /**
     * @var array
     */
    protected $config;

    /**
     * @var UserDocument
     */
    protected $currentUser;

    /**
     * @var \GearmanClient
     */
    protected $gearmanClient;

    public function setConfig($config)
    {
        $this->config = $config;
    }

    public function setCurrentUser($user)
    {
        $this->currentUser = $user;
    }

    private function setupGearman()
    {
        $this->gearmanClient = new \GearmanClient();
        $this->gearmanClient->addServer($this->conf['gearman']['host'], $this->conf['gearman']['port']);
    }

    public function addTask($eventName, $data)
    {
        if (!$this->gearmanClient) {
            $this->setupGearman();
        }

        $this->gearmanClient->addTask($eventName, $data);
    }

    protected function runTasks()
    {
        $this->gearmanClient->runTasks();
    }
}