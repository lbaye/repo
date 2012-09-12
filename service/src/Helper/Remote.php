<?php

namespace Helper;

class Remote
{
    public static function sendGetRequest($url, $data = array(), $headers = array())
    {
        if (!empty($data)) {
            $url = $url .'?'. http_build_query($data);
        }

//        $http = new \HttpRequest($url);
//        $http->setMethod($http::METH_GET);
//        $http->addHeaders($headers);
//        $http->send();

        $responseBody = file_get_contents($url); //$http->getResponseBody();
        $responseCode = 200; //$http->getResponseCode();

        return array($responseCode, $responseBody);
    }

    public static function sendPutRequest($url, $data = array(), $headers = array())
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

    public static function sendPostRequest($url, $data = array(), $headers = array())
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

    public static function sendDeleteRequest($url, $headers = array())
    {
        $http = new \HttpRequest($url);
        $http->setMethod(\HttpRequest::METH_DELETE);
        $http->addHeaders($headers);
        $http->send();

        $responseBody = $http->getResponseBody();
        $responseCode = $http->getResponseCode();

        return array($responseCode, $responseBody);
    }
}