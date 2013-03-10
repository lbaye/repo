<?php

namespace Helper;

use Monolog\Logger as Logger,
    Monolog\Handler\StreamHandler as StreamHandler;

/**
 * Utility class for storing commonly used helper methods.
 */
class Util {
    static $streamHandlers = array();

    public static function debug($obj, $depth) {
        \Doctrine\Common\Util\Debug::dump($obj, $depth);
    }

    #!/usr/bin/env php
    # This function prints the difference between two php datetime objects
    # in a more human readable form
    # inputs should be like strtotime($date)
    # Adapted from https://gist.github.com/207624 python version
    # Taken from - https://gist.github.com/1053741

    public static function humanizeTimeDiff($diff)
    {
        if ($diff < 60) {
            return $diff . " " . Util::pluralizee("second", $diff) . " ago";
        } elseif ($diff < 3600) {
            return (int)($diff / 60) . " " . Util::pluralizee("minute", (int)($diff / 60)) . " ago";
        } elseif ($diff < (3600 * 24)) {
            return (int)($diff / 3600) . " " . Util::pluralizee("hour", (int)($diff / 3600)) . " ago";
        } elseif ($diff < (3600 * 24 * 30)) {
            return (int)($diff / (3600 * 24)) . " " . Util::pluralizee("day", (int)($diff / (3600*24))) . " ago";
        } elseif ($diff < (3600 * 24 * 365)) {
            return (int)($diff / (3600 * 24 * 30)) . " " . Util::pluralizee("month", (int)($diff / (3600*24*30))) . " ago";
        } else {
            return (int)($diff / (3600 * 24 * 365)) . " " . Util::pluralizee("year", (int)($diff / (3600 * 24 * 365))) . " ago";
        }
    }

    public static function pluralizee($string , $val){
        if($val != 1){
            return $string . "s";
        } else{
            return $string;
        }
    }
    public static function toHumanizeDate($now, $otherDate = null, $offset = null) {
        if ($otherDate != null) {
            $offset = $now - $otherDate;
        }
        if ($offset != null) {
            $deltaS = $offset % 60;
            $offset /= 60;
            $deltaM = $offset % 60;
            $offset /= 60;
            $deltaH = $offset % 24;
            $offset /= 24;
            $deltaD = ($offset > 1) ? ceil($offset) : $offset;
        } else {
            throw new Exception("Must supply otherdate or offset (from now)");
        }
        if ($deltaD > 1) {
            if ($deltaD > 365) {
                $years = ceil($deltaD / 365);
                if ($years == 1) {
                    return "last year";
                } else {
                    return "<br>$years years ago";
                }
            }
            if ($deltaD > 6) {
                return date('d-M', strtotime("$deltaD days ago"));
            }
            return "$deltaD days ago";
        }
        if ($deltaD == 1) {
            return "Yesterday";
        }
        if ($deltaH == 1) {
            return "last hour";
        }
        if ($deltaM == 1) {
            return "last minute";
        }
        if ($deltaH > 0) {
            return $deltaH . " hours ago";
        }
        if ($deltaM > 0) {
            return $deltaM . " minutes ago";
        }
        else {
            return "few seconds ago";
        }
    }

    public static function getStreamHandler($config) {
        if (isset(self::$streamHandlers[APPLICATION_ENV]))
            return self::$streamHandlers[APPLICATION_ENV];

        return self::$streamHandlers[APPLICATION_ENV] = self::createStreamHandler($config);
    }

    private static function createStreamHandler($config) {
        $config = isset($config['logging']) ? $config['logging'] : array();
        $level = Logger::DEBUG;
        $file = "%s/logs/web_%s.log";

        if (isset($config['level']) && !empty($config['level']))
            $level = self::decideLoggingLevel($config['level']);

        if (isset($config['file']) && !empty($config['file']))
            $file = $config['file'];

        return new StreamHandler(sprintf($file, ROOTDIR . '/../', APPLICATION_ENV), $level);
    }

    private static function decideLoggingLevel($level) {
        switch (strtoupper($level)) {
            case 'DEBUG':
                return Logger::DEBUG;
            case 'WARN':
                return Logger::WARNING;
            case 'WARNING':
                return Logger::WARNING;
            case 'ERROR':
                return Logger::ERROR;
            case 'INFO':
                return Logger::INFO;
            case 'CRITICAL':
                return Logger::CRITICAL;
            case 'NOTICE':
                return Logger::NOTICE;

            default:
                return \Logger::INFO;
        }
    }

    public static function formatAddress($address) {
        $parts = preg_split('/,\s*/', $address);
        if (count($parts) > 0) return $parts[0];
        else return $address;
    }
}