<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class PlacesTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;

    protected $user1Headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');
    protected $user2Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01341e22c145USER2');
    protected $user3Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01342e22c145USER3');

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/places';
        restoreDatabase();
    }

    public function testPlaceCreateWorks()
    {
        $data = array(
            'lat' => 66.77,
            'lng' => 88.99,
            'title' => 'Testing place creation'
        );

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $data, $this->user1Headers);

        $this->assertEquals(201, $responseCode);

        $content = json_decode($responseBody);
        $this->assertEquals($data['title'], $content->title);
        $this->assertEquals($data['lat'], $content->location->lat);
        $this->assertEquals('5003dffe757df2010d000000', $content->owner);
    }

    public function testPlaceAccessWillCheckPermission()
    {
        // Accessing User1's private Event
        list($responseCodeForUser1, $responseBody) = sendGetRequest($this->endpoint .'/5003e750757df2000d000001', array(), $this->user1Headers);
        list($responseCodeForUser2, $responseBody) = sendGetRequest($this->endpoint .'/5003e750757df2000d000001', array(), $this->user2Headers);

        $this->assertEquals(200, $responseCodeForUser1);
        $this->assertEquals(403, $responseCodeForUser2);
    }

    public function testPlaceListWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->user1Headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertTrue(is_array($content));
        $this->assertEquals(3, count($content));
    }

    public function testPrivatePlacesAreFilteredFromOthers()
    {
        // One Place of User1 is private so should not be listed for User2
        list($responseCode, $responseBody1) = sendGetRequest($this->endpoint, array(), $this->user1Headers);
        list($responseCode, $responseBody2) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser1 = json_decode($responseBody1);
        $retrievedForUser2 = json_decode($responseBody2);

        $this->assertSame(3, count($retrievedForUser1));
        $this->assertSame(2, count($retrievedForUser2));
    }

    public function testPlaceWillBeListedForPermittedUsers()
    {
        // Giving permission to a private Event
        $data = array(
            'permission' => 'custom',
            'permittedUsers' => array('5003e8bc757df2020d000006'),
        );
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e750757df2000d000001', $data, $this->user1Headers);

        list($responseCode, $responseBody2) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser2 = json_decode($responseBody2);

        list($responseCode, $responseBody3) = sendGetRequest($this->endpoint, array(), $this->user3Headers);
        $retrievedForUser3 = json_decode($responseBody3);

        $this->assertSame(3, count($retrievedForUser2));
        $this->assertSame(2, count($retrievedForUser3));
    }

    public function testPlaceWillBeListedForPermittedCircleUsers()
    {
        // Giving "friends" permission to a private Place
        $data = array(
            'permission' => 'custom',
            'permittedCircles' => array('5003dffe757df2010d000001'),
        );
        sendPutRequest($this->endpoint .'/5003e750757df2000d000001', $data, $this->user1Headers);

        list($responseCode, $responseBody) = sendGetRequest($this->endpoint, array(), $this->user2Headers);
        $retrievedForUser2 = json_decode($responseBody);;

        list($responseCode, $responseBody3) = sendGetRequest($this->endpoint, array(), $this->user3Headers);
        $retrievedForUser3 = json_decode($responseBody3);

        // User2 is friend of User1
        $this->assertSame(3, count($retrievedForUser2));
        $this->assertSame(2, count($retrievedForUser3));
    }

    public function testMyPlaceListWorks()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL .'/me/places', array(), $this->user1Headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertTrue(is_array($content));
        $this->assertEquals(2, count($content));
    }

    public function testPlaceCanBeRenamed()
    {
        sendPutRequest($this->endpoint .'/5003e750757df2000d000000', array('title' => 'RENAMED'), $this->user1Headers);
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint .'/5003e750757df2000d000000', array(), $this->user1Headers);

        $this->assertEquals(200, $responseCode);

        $content = json_decode($responseBody);
        $this->assertEquals('RENAMED', $content->title);
    }

    public function testPlaceCannotBeRenamedUnlessOwner()
    {
        list($responseCode, $responseBody) = sendPutRequest($this->endpoint .'/5003e6f9757df23405000000', array('title' => 'RENAMED'), $this->user1Headers);
        $this->assertEquals(401, $responseCode);
    }

    public function tearDown()
    {
        clearDatabase();
    }
}