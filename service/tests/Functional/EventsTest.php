<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;
use Document\Deal;


class EventsTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7092a5');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/events';
        restoreDatabase();
    }

    public function testCreateEventWorks()
    {
        $data = array(
            'title' => 'New event',
            'description' => 'A loooong description',
            'lat' => 90.05,
            'lng' => 80.05,
            'time' => '2012-09-15 12:30:00',
            'address' => 'a one, line, address here',
            'guests' => array('5003e8bc757df2020d000006', '5003e8bc757df2020d000000', 'an-invalid-id'),
            'permission' => 'custom',                   // Can be public|private|custom
            'permittedUsers' => array('5003e8bc757df2020d000006', '5003e8bc757df2020d000000'), // id of permitted users. optional
            'permittedCircles' => array(),              // id of permitted circles. optional
        );

        // With invalid data
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, array_slice($data, 2, 2), $this->headers);
        $this->assertEquals(406, $responseCode);

        // Insert an event
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->headers);
        $inserted = json_decode($responseBody);
        $this->assertEquals(201, $responseCode);

        // Retrieve it and check
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/'. $inserted->id, array(), $this->headers);
        $retrieved = json_decode($responseBody);
        $this->assertEquals($data['title'], $retrieved->title);
        $this->assertEquals($data['lat'], $retrieved->location->lat);
    }

    public function testEventListing()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertTrue(is_array($retrieved));
        $this->assertSame(3, count($retrieved));
    }

    public function testEventListOfCurrentUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/events', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003dffe757df2010d000000', $retrieved[0]->owner);
        $this->assertSame(2, count($retrieved));
    }

    public function testEventListOfSpecificUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/users/5003e8bc757df2020d000006/events', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003e8bc757df2020d000006', $retrieved[0]->owner);
        $this->assertSame(1, count($retrieved));
    }

    public function testEventTimeAndLocationIsEditable()
    {
        $data = array(
            'lat' => 91.05,
            'lng' => 82.05,
            'time' => '2012-10-15 12:30:00',
            'address' => 'address changed'
        );

        // Edit an event
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5020cb1c757df2ff12000002', $data, $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5020cb1c757df2ff12000002', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals($data['address'], $edited->location->address);
        $this->assertEquals($data['time'], $edited->time->date);
    }

    public function testCannotBeEditedUnlessOwner()
    {
        $data = array('address' => 'address changed');

        // Retrieve with non-owner token
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d000006', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals(401, $responseCode);
    }

    public function testEventDelete()
    {
        // Delete an event
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5020cb1c757df2ff12000000', $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5020cb1c757df2ff12000000', array(), $this->headers);
        $this->assertEquals(404, $responseCode);
    }

    public function testCannotBeDeletedUnlessOwner()
    {
        // Delete with non-owner token
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d000006', array(), $this->headers);
        $this->assertEquals(401, $responseCode);
    }


    public function tearDown()
    {
        clearDatabase();
    }
}