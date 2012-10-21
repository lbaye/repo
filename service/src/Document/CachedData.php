<?php
/**
 * Created by JetBrains PhpStorm.
 * User: azhar
 * Date: 10/20/12
 * Time: 6:58 PM
 * To change this template use File | Settings | File Templates.
 */

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;

/**
 * @ODM\Document(collection="cached_data",repositoryClass="Repository\CachedDataRepo")
 * @ODM\Index(keys={"currentLocation"="2d"})
 */
class CachedData
{

    /**
     * @ODM\Id(strategy="none")
     */
    private $id;

    /**
     * @ODM\String
     */
    private $data;

    /**
     * @ODM\String
     */
    private $type;


    public function setData($data)
    {
        $this->data = $data;
    }

    public function getData()
    {
        return $this->data;
    }

    public function setId($id)
    {
        $this->id = $id;
    }

    public function getId()
    {
        return $this->id;
    }

    public function setType($type)
    {
        $this->type = $type;
    }

    public function getType()
    {
        return $this->type;
    }


    public function isValid()
    {
        return true;
    }

}