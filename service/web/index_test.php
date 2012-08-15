<?php

use Symfony\Component\HttpFoundation\Request;

require_once __DIR__ . '/../app/autoload.php';
require_once __DIR__ . '/../app/AppBootstrap.php';
require_once __DIR__ . '/../app/AppKernel.php';

defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', 'test');

define('ROOTDIR', __DIR__);

$request = Request::createFromGlobals();
$bootstrap = new Bootstrap('test');

$kernel = new AppKernel($request, $bootstrap->dm, $bootstrap->routes, $bootstrap->conf);
$kernel->handle();