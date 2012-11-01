<?php
namespace Service\PushNotification;

use Symfony\Component\Yaml\Parser;

class PushFactory
{
    public static function getNotifier($deviceType)
    {
        /**
         * @var Notifier
         */
        $notifier = null;
        $config = self::_getServiceConfig();

        if(empty($deviceType)) return false;

        switch ($deviceType)
        {
            case 'android':
                $notifier = new GCM($config['googleGCM']['apiKey'], $config['googleGCM']['endPoint']);
                break;
            case 'iOS':
                $notifier = new IOS($config['iOSPushNotification']['pemFile'],
                                    $config['iOSPushNotification']['endPoint'],
                                    $config['iOSPushNotification']['passphrase']);
                break;
            default:
                throw new \Exception('Unknown or invalid Push Notification service type provided');
        }

        return $notifier;
    }

    private static function _getServiceConfig()
    {
        $env = $_ENV['APPLICATION_ENV'];
        $env = empty($env) ? '' : '_' . $env;

        $config_path = ROOTDIR .'/../app/config/services' . $env . '.yml';
        echo $config_path . PHP_EOL;

        $yaml = new Parser();
        return $yaml->parse(file_get_contents($config_path));
    }
}