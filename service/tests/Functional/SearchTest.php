<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class SearchTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;

    protected $user1Headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7USER1');
    protected $user2Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01341e22c145USER2');
    protected $user3Headers = array('Auth-Token' => '2cb110a54ba63027ddd041e01342e22c145USER3');

    public function setUp()
    {
        restoreDatabase();
        $this->endpoint = API_BASEURL . '/search';
    }

    public function testSearchListsUserIfNearby()
    {
        $this->markTestIncomplete('Hello Emran vai!');
    }

    public function testSearchSkipsUsersWhoBlockedMe()
    {
        $this->markTestIncomplete('Hello Emran vai!');
    }

    public function testKeywordSearchListsUsersFromAnyLocation()
    {
        $this->markTestIncomplete('Hello Emran vai!');
    }

    /**
     * Checking the fields we expect to exist are exist
     * It's just a pre state check for some other field filtering tests
     */
    public function testSearchRetrievesFieldsWithAllPermission()
    {
        $searchData = array('keyword' => 'siraj', 'lat' => 0, 'lng' => 0);

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user1Headers);
        $result = json_decode($responseBody);

        $this->assertNotNull($result->people[0]->firstName);
        $this->assertNotNull($result->people[0]->lastName);
        $this->assertNotNull($result->people[0]->email);

        return $searchData;
    }

    /**
     * @depends testSearchRetrievesFieldsWithAllPermission
     */
    public function testSearchSkipsFieldsWithNonePermission($searchData)
    {
        // Update sharing preference settings
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/settings/sharing_preference_settings', array('email' => 'none'), $this->user2Headers);

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user1Headers);
        $result = json_decode($responseBody);

        $this->assertNull($result->people[0]->email);
    }

    /**
     * @depends testSearchRetrievesFieldsWithAllPermission
     */
    public function testSearchDontSkipsFieldsWithNonePermissionForSelf($searchData)
    {
        // Update sharing preference settings
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/settings/sharing_preference_settings', array('email' => 'none'), $this->user2Headers);

        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user2Headers);
        $result = json_decode($responseBody);

        $this->assertNotNull($result->people[0]->email);
    }

    /**
     * @depends testSearchRetrievesFieldsWithAllPermission
     */
    public function testSearchSkipsFieldsWithFriendsPermissionUnlessFriend($searchData)
    {
        // Update sharing preference settings
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/settings/sharing_preference_settings', array('email' => 'friends'), $this->user2Headers);

        // User1 is friend
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user1Headers);
        $resultForUser1 = json_decode($responseBody);

        // User3 is not friend
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user3Headers);
        $resultForUser3 = json_decode($responseBody);

        $this->assertNotNull($resultForUser1->people[0]->email);
        $this->assertNull($resultForUser3->people[0]->email);
    }

    /**
     * @depends testSearchRetrievesFieldsWithAllPermission
     */
    public function testSearchSkipsFieldsWithCirclesPermissionUnlessInCircle($searchData)
    {
        // Update sharing preference settings
        list($responseCode, $responseBody) = sendPutRequest(API_BASEURL . '/settings/sharing_preference_settings', array('email' => 'circles'), $this->user2Headers);

        // User1 is in Circle
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user1Headers);
        $resultForUser1 = json_decode($responseBody);

        // User3 is not in Circle
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $searchData, $this->user3Headers);
        $resultForUser3 = json_decode($responseBody);

        $this->assertNotNull($resultForUser1->people[0]->email);
        $this->assertNull($resultForUser3->people[0]->email);
    }

    public function tearDown()
    {
        clearDatabase();
    }

}