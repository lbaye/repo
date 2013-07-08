<?php

namespace Test\Functional;

use Symfony\Component\HttpFoundation\Response;

class SetupTest extends \PHPUnit_Framework_TestCase
{
    protected $endpoint;

    public function setUp()
    {
        $this->endpoint = API_BASEURL . '/hello';
        restoreDatabase();
    }

    public function testSetupWorking()
    {
        list($responseCode, $responseBody) = sendGetRequest($this->endpoint);

        $content = json_decode($responseBody);
        $this->assertEquals(200, $responseCode);
        $this->assertEquals($content->Hello, 'World');
    }

    public function tearDown()
    {
        clearDatabase();
    }
}