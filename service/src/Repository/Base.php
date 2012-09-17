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

    public function getAll($limit = 20, $offset = 0)
    {
        return $this->findBy(array(), null, $limit, $offset);
    }

    public function getByUser(UserDocument $user)
    {
        $docs = $this->findBy(array('owner' => $user->getId()));
        return $this->_toArrayAll($docs);
    }

    public function insert($doc)
    {
        $valid  = $doc->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid Location data', 406);
        }

        $this->dm->persist($doc);
        $this->dm->flush($doc);

        return $doc;
    }

    public function delete($id)
    {
        $doc = $this->find($id);

        if (is_null($doc)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($doc);
        $this->dm->flush();
    }

    protected function _toArrayAll($results)
    {
        $docsAsArr = array();
        foreach ($results as $place) {
            $docsAsArr[] = $place->toArray();
            $docsAsArr['avatar'] = $this->config['web']['root'] . $docsAsArr['avatar'];
        }

        return $docsAsArr;
    }
}