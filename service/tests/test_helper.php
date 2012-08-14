<?php

use \Doctrine\ODM\MongoDB\DocumentManager;

define('API_BASEURL', 'http://api.social_maps.local/index_test.php');

function prepareBackupDatabase()
{
    exec("mongo socialmaps_test_backup ". __DIR__. "/scripts/clearDb.js");
    exec("mongo socialmaps_test_backup ". __DIR__. "/scripts/prepareBackup.js");
}

function clearDatabase() {
    exec("mongo socialmaps_test ". __DIR__. "/scripts/clearDb.js");
}

function restoreDatabase() {
    exec("mongo socialmaps_test ". __DIR__. "/scripts/copyDb.js");
}

function sendGetRequest($url, $data = array(), $headers = array())
{
    if(!empty($data)) $url = $url .'?'. http_build_query($data);

    $http = new \HttpRequest($url);
    $http->setMethod($http::METH_GET);
    $http->addHeaders($headers);
    $http->send();

    $responseBody = $http->getResponseBody();
    $responseCode = $http->getResponseCode();

    return array($responseCode, $responseBody);
}

function sendPutRequest($url, $data = array(), $headers = array())
{
    $http = new \HttpRequest($url);
    $http->setMethod(\HttpRequest::METH_PUT);

    $headers['Content-type'] = 'application/x-www-form-urlencoded';
    $http->addHeaders($headers);

    $http->addPutData(http_build_query($data));
    $http->send();

    $responseBody = $http->getResponseBody();
    $responseCode = $http->getResponseCode();

    return array($responseCode, $responseBody);
}

function sendPostRequest($url, $data = array(), $headers = array())
{
    $http = new \HttpRequest($url);
    $http->setMethod(\HttpRequest::METH_POST);
    $http->addHeaders($headers);
    $http->addPostFields($data);
    $http->send();

    $responseBody = $http->getResponseBody();
    $responseCode = $http->getResponseCode();

    return array($responseCode, $responseBody);
}

function sendDeleteRequest($url, $headers = array())
{
    $http = new \HttpRequest($url);
    $http->setMethod(\HttpRequest::METH_DELETE);
    $http->addHeaders($headers);
    $http->send();

    $responseBody = $http->getResponseBody();
    $responseCode = $http->getResponseCode();

    return array($responseCode, $responseBody);
}