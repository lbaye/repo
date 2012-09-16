<?php

namespace Service\Notification;

class GCM extends Base
{
    protected $apiKey;
    protected $endpoint;

    public function __construct($apiKey, $endpoint = 'https://android.googleapis.com/gcm/send')
    {
        $this->apiKey = $apiKey;
        $this->endpoint = $endpoint;
    }

    public function send(array $data, array $deviceIds)
    {
        //$apiKey = "AIzaSyCcJ6Oq6dGtVa9j3sT5kYHxxhmgQB5A020";

        // Message to be sent
        $message = "This is test message from SocialMaps";

        $fields = array(
            'registration_ids'  => $deviceIds,
            'data'              => array( "message" => $message ),
        );

        $headers = array(
            'Authorization: key=' . $this->apiKey,
            'Content-Type: application/json'
        );

        // Open connection
        $ch = curl_init();

        // Set the url, number of POST vars, POST data
        curl_setopt( $ch, CURLOPT_URL, $this->endpoint );

        curl_setopt( $ch, CURLOPT_POST, true );
        curl_setopt( $ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );

        curl_setopt( $ch, CURLOPT_POSTFIELDS, json_encode( $fields ) );

        // Execute post
        $result = curl_exec($ch);

        // Close connection
        curl_close($ch);

        return $result;
    }
}