<?php

if (isset($_SERVER['HTTP_AUTH_TOKEN'])) {
    $lat = isset($_REQUEST['lat']) ? $_REQUEST['lat'] : 0;
    $lng = isset($_REQUEST['lng']) ? $_REQUEST['lng'] : 0;
    $lat = round(((float) $lat), 3);
    $lng = round(((float) $lng), 3);

    $cacheFile = implode(DIRECTORY_SEPARATOR,
                         array(__DIR__, '..', 'app', 'cache', 'static_caches', $_SERVER['REQUEST_URI'],
                              $_SERVER['HTTP_AUTH_TOKEN'] . '-' . $lat . '-'. $lng));

    if (file_exists($cacheFile)) {
        header('Content-Type: application/json');
        echo file_get_contents($cacheFile); exit;
    }
}

# Bootstrap application
use Symfony\Component\HttpFoundation\Request;

require_once __DIR__ . '/../app/autoload.php';
require_once __DIR__ . '/../app/AppBootstrap.php';
require_once __DIR__ . '/../app/AppKernel.php';

defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : 'prod'));

define('ROOTDIR', __DIR__);

$request = Request::createFromGlobals();
$bootstrap = new Bootstrap(APPLICATION_ENV);

$kernel = new AppKernel($request, $bootstrap->dm, $bootstrap->routes, $bootstrap->conf);
$kernel->handle();