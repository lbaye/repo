<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Helper\Status;

/**
 * @ignore
 */
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

    public function GCM()
    {
        $apiKey = "AIzaSyCcJ6Oq6dGtVa9j3sT5kYHxxhmgQB5A020";

        // Replace with real client registration IDs
        $registrationIDs = array( "APA91bF1riFJPUx4yqQlm3Khr4VZUO0YDkPHkyLGDzjOaTuHE4kkysk1nbxA7CsOOfM3ypJ259r2GRpKZk_lezkH1mjhAwoz4tD6NAGLrFjjD-5D46e3iWdnoS0R6rRTeRZ0npR4NYMSctppp5wXls5yzTxJ6Uh4lg" );

        // Message to be sent
        $message = "This is test message from SocialMaps";

        // Set POST variables
        $url = 'https://android.googleapis.com/gcm/send';

        $fields = array(
            'registration_ids'  => $registrationIDs,
            'data'              => array( "message" => $message ),
        );

        $headers = array(
            'Authorization: key=' . $apiKey,
            'Content-Type: application/json'
        );

        // Open connection
        $ch = curl_init();

        // Set the url, number of POST vars, POST data
        curl_setopt( $ch, CURLOPT_URL, $url );

        curl_setopt( $ch, CURLOPT_POST, true );
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );

        curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $fields ) );

        // Execute post
        $result = curl_exec($ch);

        // Close connection
        curl_close($ch);

        $this->response->setContent($result);
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
