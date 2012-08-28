<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class UserTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;
    protected $user1Headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');
    protected $user2Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01341e22c145USER2');
    protected $user3Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01342e22c145USER3');

    public function setUp()
    {
        restoreDatabase();
        $this->endpoint = API_BASEURL . '/users';
    }

    public function testPreventUnlessCorrectAuthToken()
    {
        list($noToken, $responseBody) = sendGetRequest(API_BASEURL . '/users');
        list($wrongToken, $responseBody) = sendGetRequest(API_BASEURL . '/users', array(), array('Auth-Token' => 'A-WRONG-AUTH-TOKEN'));

        $this->assertEquals(401, $noToken);
        $this->assertEquals(401, $wrongToken);
    }

    public function testGetCurrentUser()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/me', array(), $this->user1Headers);

        $content = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals($content->id, '5003dffe757df2010d000000');
        $this->assertEquals($content->email, 'anisniit@gmail.com');
    }

    public function testUpdateLocation()
    {
        $location = array('lat' => '90.87', 'lng' => '86.67');

        // With insufficient params
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/current-location', array('lat' => 0), $this->user1Headers);
        $this->assertEquals(417, $responseCode);

        // With acceptable params
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/current-location', $location, $this->user1Headers);
        $this->assertEquals(200, $responseCode);

        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/me', array(), $this->user1Headers);
        $content = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertEquals($content->currentLocation->lat, $location['lat']);
        $this->assertEquals($content->currentLocation->lng, $location['lng']);
    }

    public function testGetNearbyUsersAreSortedByDistance()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users', array(), $this->user1Headers);
        $content = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);
        $this->assertGreaterThanOrEqual($content[0]->distance, $content[1]->distance);
    }

    public function testNearbyUsersShowsOnlyVisibleUsers()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users', array(), $this->user1Headers);
        $before = json_decode($responseBody);

        // Set location at fence
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '96', 'lng' => '88'), $this->user1Headers);
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users', array(), $this->user1Headers);
        $after = json_decode($responseBody);

        $this->assertEquals(3, count($before));
        $this->assertEquals(2, count($after));
    }

    public function testUpdatingLocationChangesVisibilityByGeoFence()
    {
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users/5003dffe757df2010d000000', array(), $this->user1Headers);
        $before = json_decode($responseBody);

        // Set geo-fence
        //sendPutRequest(API_BASEURL . '/settings/geo_fence', array('lat' => '90.87', 'lng' => '86.67', 'radius' => 5), $this->headers);
        sendPutRequest(API_BASEURL . '/settings/geo_fence', array('lat' => '90.87', 'lng' => '86.67', 'radius' => 2), $this->user1Headers);

        // Distance 1.112025 km
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '90.88', 'lng' => '86.68'), $this->user1Headers);
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users/5003dffe757df2010d000000', array(), $this->user1Headers);
        $after = json_decode($responseBody);

        // Distance 11.26095 km
        sendPutRequest(API_BASEURL . '/current-location', array('lat' => '90.97', 'lng' => '85.67'), $this->user1Headers);
        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/users/5003dffe757df2010d000000', array(), $this->user1Headers);
        $atLast = json_decode($responseBody);

        $this->assertTrue($before->visible);
        $this->assertFalse($after->visible);
        $this->assertTrue($atLast->visible);
    }

    public function testUserCanBlockAnotherUser()
    {
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/users/block/5003e8bc757df2020d000006', array(), $this->user1Headers);
        $result = json_decode($responseBody);

        $this->assertEquals(200, $responseCode);

        list($responseCode, $responseBody) = sendGetRequest(API_BASEURL . '/me', array(), $this->user1Headers);
        $userData = json_decode($responseBody);

        $blockedUsers = $userData->blockedUsers;
        $this->assertTrue(in_array('5003e8bc757df2020d000006', $blockedUsers));
    }

    public function tearDown()
    {
        clearDatabase();
    }

}