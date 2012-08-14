<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class GeotagsTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7092a5');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/geotags';
        restoreDatabase();
    }

    public function testGeotagCreateWorks()
    {
        $data = array(
            'lat' => 66.77,
            'lng' => 88.99,
            'title' => 'Testing place creation'
        );

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->headers);

        $this->assertEquals(201, $responseCode);

        $content = json_decode($responseBody);
        $this->assertEquals($data['title'], $content->title);
        $this->assertEquals($data['lat'], $content->location->lat);
        $this->assertEquals('5003dffe757df2010d000000', $content->owner);

        // Check count increased
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $content = json_decode($responseBody);
        $this->assertEquals(3, count($content));
    }

    public function testGeotagsListWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertTrue(is_array($content));
        $this->assertEquals(2, count($content));
    }

    public function testMyGeotagsListWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/geotags', array(), $this->headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertTrue(is_array($content));
        $this->assertEquals(1, count($content));
    }

    public function testGeotagCanBeRenamed()
    {
        sendPutRequest($this->endpoint .'/5003e6f9757df23405000008', array('title' => 'RENAMED'), $this->headers);
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e6f9757df23405000008', array(), $this->headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertEquals('RENAMED', $content->title);
    }

    public function testGeotagCannotBeRenamedUnlessOwner()
    {
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e6f9757df23405000009', array('title' => 'RENAMED'), $this->headers);
        $this->assertEquals(401, $responseCode);
    }

    public function tearDown()
    {
        clearDatabase();
    }
}