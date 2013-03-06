<?php

namespace Service\PushNotification;

/**
 * Android GCM compatible push notification implementation
 */
class GCM extends Notifier
{
    public function __construct($apiKey, $endpoint = 'https://android.googleapis.com/gcm/send')
    {
        parent::__construct($apiKey, $endpoint);
    }

    public function send(array $data, array $deviceIds)
    {
        $fields = array(
            'registration_ids'  => $deviceIds,
            'data'              => $this->_createPushData($data),
        );

        $headers = array(
            'Authorization: key=' . $this->apiKey,
            'Content-Type: application/json'
        );

        return $this->_sendToGCM($headers, $fields);
    }

    private function _createPushData($data)
    {
        $pushData = array(
            'message'    => $data['title'],
            'badge'      => $data['badge'],
            'tabCounts'  => $data['tabCounts'],
            'objectType' => $data['objectType'],
            'objectId'   => isset($data['objectId']) ? $data['objectId'] : null,
            'receiverId' => $data['receiverId'],
            'testReceive' => "121212"
        );

        return $pushData;
    }

    private function _sendToGCM($headers, $fields)
    {
        $ch = curl_init();

        curl_setopt($ch, CURLOPT_URL, $this->endpoint);

        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        // curl_setopt($ch, CURLOPT_VERBOSE, true);

        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));

        $result = curl_exec($ch);
        curl_close($ch);

        return $result;
    }
}