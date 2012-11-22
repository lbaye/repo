<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Yaml\Parser;
use Helper\Status;

class About extends Base
{

    /**
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();
        $this->createLogger('Controller::About');
        $this->info('Completed controller initialization');
    }

    /**
     * GET /about
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
