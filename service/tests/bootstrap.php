<?php

define("TEST_DIR", realpath(__DIR__));

require_once __DIR__ . '/../app/autoload.php';
require_once __DIR__ . '/../app/AppBootstrap.php';
require_once __DIR__ . '/test_helper.php';

// Create the backup database from where test will be restored
prepareBackupDatabase();

$bootstrap = new Bootstrap('test');
$bootstrap->dm->getConnection()->connect();

//prepareTestDatabase(__DIR__ . '/../src/Document', $bootstrap->dm);

global $dm;
$dm = $bootstrap->dm;
