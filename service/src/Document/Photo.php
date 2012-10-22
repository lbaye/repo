<?php

namespace Document;

use Doctrine\ODM\MongoDB\Mapping\Annotations as ODM;
use Respect\Validation\Validator;

/**
 * @ODM\Document(collection="photos",repositoryClass="Repository\PhotoRepo")
 */
/**
 * @ODM\Document
 */
class Photo extends User
{
    /** @ODM\Id */
    protected $id;

    /** @ODM\File */
    protected $file;

    /** @ODM\String */
    protected $fileName;

    /** @ODM\String */
    protected $mimeType;

    /** @ODM\Date */
    protected $uploadDate;

    /** @ODM\Int */
    protected $length;

    /** @ODM\Int */
    protected $chunkSize;

    /** @ODM\String */
    protected $md5;

    public function getFile()
    {
        return $this->file;
    }

    public function setFile($file)
    {
        $this->file = $file;
    }

    public function getFileName()
    {
        return $this->filename;
    }

    public function setFileName($fileName)
    {
        $this->fileName = $fileName;
    }

    public function getMimeType()
    {
        return $this->mimeType;
    }

    public function setMimeType($mimeType)
    {
        $this->mimeType = $mimeType;
    }

    public function getChunkSize()
    {
        return $this->chunkSize;
    }

    public function getLength()
    {
        return $this->length;
    }

    public function getMd5()
    {
        return $this->md5;
    }

    public function getUploadDate()
    {
        return $this->uploadDate;
    }
}