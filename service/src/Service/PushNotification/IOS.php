<?php

namespace Service\PushNotification;

class IOS extends Notifier
{
    protected $pemFile = null;
    protected $passphrase = null;

    public function __construct($pemFile, $endpoint = 'ssl://gateway.sandbox.push.apple.com:2195', $passphrase = null)
    {
        parent::__construct($pemFile, $endpoint);
        $this->pemFile = $this->apiKey;

        if($passphrase) $this->passphrase = $passphrase;
    }

    public function send(array $data, array $deviceIds)
    {
        // Create a stream to the server
        $streamContext = $this->_getStreamContext();
        $apns = stream_socket_client($this->endpoint, $error, $errorString, 60, STREAM_CLIENT_CONNECT, $streamContext);

        // Now we need to create JSON which can be sent to APNS
        $payload = $this->_createPayload($data);

        // The payload needs to be packed before it can be sent
        $apnsMessage = $this->_packMessage($deviceIds, $payload);

        // Write the payload to the APNS
        fwrite($apns, $apnsMessage);
        echo "just wrote payload: " . $payload;

        // Close the connection
        fclose($apns);

        return empty($error)? 'OK'.PHP_EOL : $errorString.PHP_EOL;
    }

    public function _packMessage($deviceIds, $payload)
    {
        $apnsMessage = chr(0) . chr(0) . chr(32);
        $apnsMessage .= pack('H*', str_replace(' ', '', $deviceIds[0]));
        $apnsMessage .= chr(0) . chr(strlen($payload)) . $payload;
        return $apnsMessage;
    }

    private function _createPayload($data)
    {
        $load = array(
            'aps' => array(
                'alert' => substr($data['title'], 0, 30),
                'badge' => 1,
                "custom_data" => array(
                    'objectType' => $data['objectType'],
                    'objectId' => isset($data['objectId']) ? $data['objectId'] : 0,
                )
            )
        );

        $payload = json_encode($load);
        return $payload;
    }

    private function _getStreamContext()
    {
        $streamContext = stream_context_create();
        stream_context_set_option($streamContext, 'ssl', 'local_cert', ROOTDIR . '/../' . $this->pemFile);
        stream_context_set_option($streamContext, 'ssl', 'passphrase', $this->passphrase);
        return $streamContext;
    }
}