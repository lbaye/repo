<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;
use Document\Deal;


class PlansTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/plans';
        restoreDatabase();
    }

    public function testCreatePlanWorks()
    {
        $data = array(
            'title' => 'New Plan',
            'lat' => 90.05,
            'lng' => 80.05,
            'time' => '2012-09-15 12:30:00',
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

    public function testPlanListingWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertTrue(is_array($retrieved));
        $this->assertSame(2, count($retrieved));
    }

    public function testPlanListOfCurrentUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/plans', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003dffe757df2010d000000', $retrieved[0]->owner);
        $this->assertSame(1, count($retrieved));
    }

    public function testPlanListOfSpecificUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/users/5003e8bc757df2020d000000/plans', array(), $this->headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003e8bc757df2020d000000', $retrieved[0]->owner);
        $this->assertSame(1, count($retrieved));
    }

    public function testPlanTimeAndLocationIsEditable()
    {
        $data = array(
            'lat' => 91.55,
            'lng' => 82.05,
            'time' => '2012-10-15 12:30:00'
        );

        // Edit an event
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0060', $data, $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0060', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals($data['lat'], $edited->location->lat);
        $this->assertEquals($data['time'], $edited->time->date);
    }

    public function testCannotBeEditedUnlessOwner()
    {
        $data = array('time' => '2012-10-15 12:40:00');

        // Retrieve with non-owner token
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0061', array(), $this->headers);
        $edited = json_decode($responseBody);

        $this->assertEquals(401, $responseCode);
    }

    public function testPlanDelete()
    {
        // Delete an event
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0060', $this->headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0060', array(), $this->headers);
        $this->assertEquals(404, $responseCode);
    }

    public function testCannotBeDeletedUnlessOwner()
    {
        // Delete with non-owner token
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0061', array(), $this->headers);
        $this->assertEquals(401, $responseCode);
    }


    public function tearDown()
    {
        clearDatabase();
    }
}