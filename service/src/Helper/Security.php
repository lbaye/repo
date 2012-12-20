<?php

namespace Helper;

/**
 * @ignore
 */
class Security
{
    public static function hash($string, $salt)
    {
        return sha1($string . $salt);
    }
}