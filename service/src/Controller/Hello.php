<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;

class Hello extends Base
{
    public function world()
    {

        $this->response->setContent(json_encode(array('Hello' => 'World')));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    public function gearman()
    {
        $dateStr = date('Y-m-d H:i:s');
        $this->addTask('test_event', 'Gearman working : '. $dateStr);

        $this->response->setContent(json_encode(array('message' => 'Check /tmp/workload.txt shows wokring message at '. $dateStr)));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    public function test()
    {
        $circleData = $this->request->request->all();

        $usrRep = $this->dm->getRepository('Document\User');
        $usrRep->setCurrentUser($this->user);
        $usrRep->addCircle($circleData);

        $response = new Response();

        $response->headers->set('Content-Type', 'application/json');
        $response->setContent(json_encode(array('test'=>'working')));
        $response->setStatusCode(Status::OK);

        return $response;
    }
}