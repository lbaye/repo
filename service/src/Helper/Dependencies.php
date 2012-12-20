<?php
namespace Helper;

/**
 * Helper for exposing dependent instances
 */
class Dependencies {

    /**
     * @var \Doctrine\ODM\MongoDB\DocumentManager
     */
    public static $dm = null;
    public static $rootUrl = null;
}