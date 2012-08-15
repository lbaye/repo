<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;
use Document\Deal;


class MeetupsTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/meetups';
        restoreDatabase();
    }

    public function testCreateMeetupWorks()
    {
        $data = array(
            'title' => 'New deal',
            'description' => 'A loooong description',   // Message here
            'duration'=> '2 hours',                     // Textual duration info
            'lat' => 90.05,
            'lng' => 80.05,
            'time' => '2012-09-15 12:30:00',            // Time duration
            'address' => 'a one, line, address here',
            'guests' => array('5003e8bc757df2020d000006', '5003e8bc757df2020d000000', 'an-invalid-id'),
            'permission' => 'custom',                   // Can be public|private|custom
            'permittedUsers' => array('5003e8bc757df2020d000006', '5003e8bc757df2020d000000'), // id of permitted users. optional
            'permittedCircles' => array(),              // id of permitted circles. optional
        );

        // With invalid data
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, array_slice($data, 2, 2), $this->headers);
        $this->assertEquals(406, $responseCode);

        // Insert an meetup
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->headers);
        $inserted = json_decode($responseBody);
        $this->assertEquals(201, $responseCode);

        // Retrieve it and check
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/'. $inserted->id, array(), $this->headers);
        $retrieved = json_decode($responseBody);
        $this->assertEquals($retrieved->title, $data['title']);
        $this->assertEquals($data['lat'], $retrieved->location->lat);
        $this->assertEquals(2, count($retrieved->guests));
    }

    public function testMeetupListing()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertTrue(is_array($retrieved));
        $this->assertSame(2, count($retrieved));
    }

    public function testMeetupListOfCurrentUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/meetups', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003dffe757df2010d000000', $retrieved[0]->owner);
        $this->assertSame(1, count($retrieved));
    }

    public function testMeetupListOfSpecificUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/users/5003e8bc757df2020d000000/meetups', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003e8bc757df2020d000000', $retrieved[0]->owner);
        $this->assertSame(1, count($retrieved));
    }

    public function testEventTitleTimeAndLocationIsEditable()
    {
        $data = array(
            'title' => 'Updated title',
            'lat' => 91.05,
            'lng' => 82.05,
            'time' => '2012-10-15 12:30:00',
            'address' => 'address changed'
        );

        // Edit an meetup
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0000', $data, $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0000', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals($data['title'], $edited->title);
        $this->assertEquals($data['address'], $edited->location->address);
        $this->assertEquals($data['time'], $edited->time->date);
    }

    public function testMeetupCannotBeEditedUnlessOwner()
    {
        $data = array('address' => 'address changed');

        // Retrieve with non-owner token
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0001', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals(401, $responseCode);
    }

    public function testEventDelete()
    {
        // Delete an meetup
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0000', $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0000', array(), $this->headers);
        $this->assertEquals(404, $responseCode);
    }

    public function testCannotBeDeletedUnlessOwner()
    {
        // Delete with non-owner token
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0001', array(), $this->headers);
        $this->assertEquals(401, $responseCode);
    }


    public function tearDown()
    {
        clearDatabase();
    }
}