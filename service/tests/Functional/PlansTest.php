<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;
use Document\Deal;


class PlansTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;

    protected $user1Headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');
    protected $user2Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01341e22c145USER2');
    protected $user3Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01342e22c145USER3');

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
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, array_slice($data, 2, 2), $this->user1Headers);
        $this->assertEquals(406, $responseCode);

        // Insert an event
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->user1Headers);
        $inserted = json_decode($responseBody);
        $this->assertEquals(201, $responseCode);

        // Retrieve it and check
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/'. $inserted->id, array(), $this->user1Headers);
        $retrieved = json_decode($responseBody);
        $this->assertEquals($data['title'], $retrieved->title);
        $this->assertEquals($data['lat'], $retrieved->location->lat);
    }

    public function testEventAccessWillCheckPermission()
    {
        // Accessing User1's private Event
        list($responseCodeForUser1, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0068', array(), $this->user1Headers);
        list($responseCodeForUser2, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0068', array(), $this->user2Headers);

        $this->assertEquals(200, $responseCodeForUser1);
        $this->assertEquals(403, $responseCodeForUser2);

    }

    public function testPlanListingWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->user1Headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertTrue(is_array($retrieved));
        $this->assertSame(3, count($retrieved));
    }

        public function testPrivateEventsAreFilteredFromOthers()
    {
        // One event of User1 is private so should not be listed for User2
        list($responseCode, $responseBody1) = sendGetRequest($this->endpoint, array(), $this->user1Headers);
        list($responseCode, $responseBody2) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser1 = json_decode($responseBody1);
        $retrievedForUser2 = json_decode($responseBody2);

        $this->assertSame(3, count($retrievedForUser1));
        $this->assertSame(2, count($retrievedForUser2));
    }

    public function testEventWillBeListedForPermittedUsers()
    {
        // Giving permission to a private Event
        $data = array(
            'permission' => 'custom',
            'permittedUsers' => array('5003e8bc757df2020d000006'),
        );
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0068', $data, $this->user1Headers);

        list($responseCode, $responseBody2) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser2 = json_decode($responseBody2);

        list($responseCode, $responseBody3) = sendGetRequest($this->endpoint, array(), $this->user3Headers);
        $retrievedForUser3 = json_decode($responseBody3);

        $this->assertSame(3, count($retrievedForUser2));
        $this->assertSame(2, count($retrievedForUser3));
    }

    public function testEventWillBeListedForPermittedCircleUsers()
    {
        // Giving "friends" permission to a private Event
        $data = array(
            'permission' => 'custom',
            'permittedCircles' => array('5003dffe757df2010d000001'),
        );
        sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0068', $data, $this->user1Headers);

        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser2 = json_decode($responseBody);;

        list($responseCode, $responseBody3) = sendGetRequest($this->endpoint, array(), $this->user3Headers);
        $retrievedForUser3 = json_decode($responseBody3);

        // User2 is friend of User1
        $this->assertSame(3, count($retrievedForUser2));
        $this->assertSame(2, count($retrievedForUser3));
    }


    public function testPlanListOfCurrentUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/plans', array(), $this->user1Headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003dffe757df2010d000000', $retrieved[0]->owner);
        $this->assertSame(2, count($retrieved));
    }

    public function testPlanListOfSpecificUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/users/5003e8bc757df2020d000006/plans', array(), $this->user1Headers);
        $retrieved = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals('5003e8bc757df2020d000006', $retrieved[0]->owner);
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
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0060', $data, $this->user1Headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0060', array(), $this->user1Headers);
        $edited = json_decode($responseBody);

        $this->assertEquals($data['lat'], $edited->location->lat);
        $this->assertEquals($data['time'], $edited->time->date);
    }

    public function testCannotBeEditedUnlessOwner()
    {
        $data = array('time' => '2012-10-15 12:40:00');

        // Retrieve with non-owner token
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e8bc757df2020d0f0061', array(), $this->user1Headers);
        $edited = json_decode($responseBody);

        $this->assertEquals(401, $responseCode);
    }

    public function testPlanDelete()
    {
        // Delete an event
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0060', $this->user1Headers);
        $this->assertEquals(200, $responseCode);

        // Retrieve it again
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e8bc757df2020d0f0060', array(), $this->user1Headers);
        $this->assertEquals(404, $responseCode);
    }

    public function testCannotBeDeletedUnlessOwner()
    {
        // Delete with non-owner token
        list($responseCode, $responseBody) = sendDeleteRequest($this->endpoint .'/5003e8bc757df2020d0f0061', array(), $this->user1Headers);
        $this->assertEquals(401, $responseCode);
    }


    public function tearDown()
    {
        clearDatabase();
    }
}