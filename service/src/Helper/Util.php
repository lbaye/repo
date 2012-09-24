<?php

namespace Helper;

class Util
{
    public static function debug($obj, $depth)
    {
        \Doctrine\Common\Util\Debug::dump($obj, $depth);
    }
}