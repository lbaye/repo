<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;
use Document\Deal;


class DealsTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/deals';
        restoreDatabase();
    }

    public function testCreateDeals()
    {
        $data = array(
            'title' => 'New deal',
            'lat' => 90.05,
            'lng' => 80.05,
            'expiration' => '2012-09-15 12:30:00',
            'description' => 'A loooong description',
            "category" => "cafe",
            "link" => "http://www.bracbank.com/",
            "maplink" => "http://www.another.com",
        );

        // With invalid data$data
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, array_slice($data, 0, 2), $this->headers);
        $this->assertEquals(406, $responseCode);

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->headers);
        $content = json_decode($responseBody);

        $this->assertEquals(201, $responseCode);
        $this->assertEquals($content->title, $data['title']);
    }

    public function testGetNearbyDeals()
    {
        $location = array('lat' => '91', 'lng' => '81');
        // Update Users current location first
        sendPutRequest(API_BASEURL . '/current-location', $location, $this->headers);
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertTrue(is_array($content));
    }

    public function testNearbyDealsMaintainsOrder()
    {
        // Update Users current location first
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '91', 'lng' => '81'), $this->headers);
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $deals = json_decode($responseBody);

        $this->assertLessThanOrEqual($deals[1]->distance,  $deals[0]->distance);
    }

    public function tearDown()
    {
        clearDatabase();
    }
}