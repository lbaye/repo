<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;

class Hello extends Base
{
    public function world()
    {
        $response = new Response();

        $response->headers->set('Content-Type', 'application/json');
        $response->setContent(json_encode(array('Hello' => 'World')));
        $response->setStatusCode(Status::OK);

        return $response;
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