<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class MessageTest extends \PHPUnit_Framework_TestCase {
    protected $endpoint;
    protected $headers = array('Auth-Token' => '6d16c898c3e9184cf35e65854376685a7f7092a5');

    public function setUp() {
        $this->endpoint = API_BASEURL . '/messages';
        restoreDatabase();
    }

    public function test_create_message_with_single_recipient() {
        $params = array(
            'subject' => 'Hi there',
            'content' => 'Hi content',
            'sender' => '501f9e50e922a17a7b000000',
            'recipients' => array('501f9e50e922a17a7b000000')
        );
        list($responseCode, $responseBody) = sendPostRequest($this->endpoint, $params, $this->headers);
        echo $responseBody;
        $this->assertEquals(201, $responseCode);

    }

    public function test_create_message_with_multiple_recipients() {
    }

    public function test_retrieve_all_user_messages() {
    }

}