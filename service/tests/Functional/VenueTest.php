<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class VenueTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7092a5');

    public function setUp()
    {
        restoreDatabase();
        $this->endpoint = API_BASEURL . '/venues';
    }

    public function testVenuesAdaptedToExpectedFormat()
    {
        // Set location to google Sydney
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '-33.8670522', 'lng' => '151.1957362'), $this->headers);

        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $this->assertEquals(200, $responseCode);

        $venues = json_decode($responseBody);
        if(empty($venues)){
            $this->markTestSkipped("Cannot test venues API without internet!");
        } else {
            $venue = $venues[0];

            $this->assertObjectHasAttribute('id', $venue);
            $this->assertObjectHasAttribute('name', $venue);
            $this->assertObjectHasAttribute('icon', $venue);
            $this->assertObjectHasAttribute('location', $venue);
            $this->assertObjectHasAttribute('reference', $venue);
            $this->assertObjectHasAttribute('types', $venue);
        }
    }

    public function testKeepSilentForEmptyResult()
    {
        // Set location to google Sydney
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '20', 'lng' => '30'), $this->headers);

        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $venues = json_decode($responseBody);
        if(empty($venues)){
            $this->markTestSkipped("Cannot test venues API without internet!");
        } else {
            $this->assertEquals(204, $responseCode);
        }
    }

    public function tearDown()
    {
        clearDatabase();
    }
}