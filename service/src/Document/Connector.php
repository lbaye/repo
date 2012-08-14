<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\EmbeddedDocument
 */
class Connector
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\String */
    protected $siteName;

    /** @ODM\String */
    protected $handle;

    /** @ODM\String */
    protected $authToken;

    /** @ODM\Boolean */
    protected $enabled;

   function __construct(array $data = null)
    {
        if(!is_null($data)){
            $this->map($data);
        }

        return $this;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setSiteName($siteName)
    {
        $this->siteName = $siteName;
    }

    public function getSiteName()
    {
        return $this->siteName ;
    }

    public function setHandle($handle)
    {
        $this->handle = $handle;
    }

    public function getHandle()
    {
        return $this->handle;
    }

    public function setAuthToken($authToken)
    {
        $this->authToken = $authToken;
    }

    public function getAuthToken()
    {
        return $this->authToken ;
    }

    public function setEnabled($enabled)
    {
        $this->enabled = $enabled;
    }

    public function getEnabled()
    {
        return $this->enabled;
    }

    public function toArray()
    {
        $fieldsToExpose = array('id', 'siteName', 'handle', 'authToken', 'enabled');
        $result = array();

        foreach($fieldsToExpose as $field) {
            $result[$field] = $this->{"get{$field}"}();
        }

        return $result;
    }

    public function map(array $data)
    {
        $setIfExistFields = array('id', 'siteName', 'handle', 'authToken', 'enabled');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $this->{"set{$field}"}($data[$field]);
            }
        }

        return $this;
    }

    public function isValid()
    {
        try {
            Validator::create()->notEmpty()->assert($this->getSiteName());
            Validator::create()->notEmpty()->assert($this->getHandle());
            Validator::create()->notEmpty()->assert($this->getAuthToken());
            Validator::create()->bool()->assert($this->getEnabled());
            } catch (\InvalidArgumentException $e) {
            return false;
        }

        return true;
    }
}