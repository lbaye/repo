<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Yaml\Parser;
use Helper\Status;

/**
 * Describe API's current version and compatibility level
 */
class About extends Base
{

    public function init()
    {
        parent::init();
        $this->createLogger('Controller::About');
        $this->info('Completed controller initialization');
    }

    /**
     * GET /about
     *
     * Read 'config/version.yml' file for current API status.
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function index()
    {
        $yaml = new Parser();
        $version =  $yaml->parse(file_get_contents(__DIR__ . '/../../app/config/version.yml'));
        $this->response->setContent(json_encode($version['about']));
        $this->response->setStatusCode(Status::OK);
        return $this->response;
    }

}
