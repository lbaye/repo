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
        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient = new \GearmanClient();
            $this->gearmanClient->addServer($this->config['gearman']['host'], $this->config['gearman']['port']);
        }
    }

    public function addTask($eventName, $data)
    {
        if (!$this->gearmanClient) {
            $this->setupGearman();
        }

        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient->doBackground($eventName, $data);
        }
    }
}