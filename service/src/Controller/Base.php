<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Doctrine\ODM\MongoDB\DocumentManager;
use Repository\UserRepo as userRepository;

use Helper\Status;
use Helper\ShareConstant;

abstract class Base
{
    /**
     * @var \Symfony\Component\HttpFoundation\Request
     */
    protected $request;

    /**
     * @var \Doctrine\ODM\MongoDB\DocumentManager
     */
    protected $dm;

    /**
     * @var \Symfony\Component\HttpFoundation\Response;
     */
    protected $response;

    /**
     * @var array
     */
    protected $config;

    /**
     * @var \Document\User
     */
    protected $user;

    /**
     * @var UserRepository
     */
    protected $userRepository;


    /**
     * @var \Service\Serializer\Serializable
     */
    protected $serializer;

    /**
     * @var \GearmanClient
     */
    protected $gearmanClient;

    protected $missingFields;

    /**
     * Inject the Request object for further use.
     *
     * @param \Symfony\Component\HttpFoundation\Request $request
     */
    public function setRequest($request)
    {
        $this->request = $request;
    }

    /**
     * Inject the DocumentManager for further communication with MongoDB.
     *
     * @param \Doctrine\ODM\MongoDB\DocumentManager $dm
     */
    public function setDocumentManager($dm)
    {
        $this->dm = $dm;
    }

    /**
     * Load the requesting user's object if provided in the header.
     */
    public function setSessionUser()
    {
        if ($this->request->headers->has('Auth-Token')) {
            $authToken  = $this->request->headers->get('Auth-Token');
            $this->user = $this->dm->getRepository('Document\User')->getByAuthToken($authToken);
        }
    }

    /**
     * Inject the configuration.
     *
     * @param $config array
     */
    public function setConfiguration($config)
    {
        $this->config = $config;
    }

    /**
     * Initializer function to be used by child classes.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->serializer = \Service\Serializer\Factory::getSerializer('json');
    }

    protected function addTask($eventName, $data)
    {
        if (!$this->gearmanClient) {
            $this->setupGearman();
        }

        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient->doBackground($eventName, $data);
        }
    }

    /**
     * Ensure if a User has been set as currentUser.
     */
    protected function _ensureLoggedIn()
    {
        if (!$this->user instanceof \Document\User) {
            $this->response->setContent(json_encode(array('message' => 'Unauthorized (Wrong or no Auth-Token provided!)')));
            $this->response->setStatusCode(Status::UNAUTHORIZED);
            $this->response->send();
            exit;
        }
    }

    protected function _filterByPermission($documents)
    {
        $permittedDocs = array();

        foreach($documents as $doc) {
            if($doc->isPermittedFor($this->user)) {
                $permittedDocs[] = $doc;
            }
        }

        return $permittedDocs;
    }

    protected function _toArrayAll(array $results)
    {
        $arrayItems = array();
        foreach ($results as $doc) {
            $arrayItems[] = $doc->toArray();
        }

        return $arrayItems;
    }

    protected function _generateResponse($hash, $code = Status::OK, $options = array())
    {
        if (!empty($hash)) {
            $this->response->setContent(
                $this->serializer->serialize($hash, $options)
            );
            $this->response->setStatusCode($code);
        } else {
            $this->response->setContent('[]'); // No content
            $this->response->setStatusCode($code);
        }

        return $this->response;
    }

    protected function _generateErrorResponse($message, $code = Status::NOT_ACCEPTABLE)
    {
        return $this->_generateResponse(array(
            'message' => $message
        ), $code);
    }

    protected function _generate404()
    {
        return $this->_generateErrorResponse('Object not found', Status::NOT_FOUND);
    }

    protected function _generate500($message = 'Failed to update object')
    {
        return $this->_generateErrorResponse($message, Status::INTERNAL_SERVER_ERR);
    }

    protected function _generateUnauthorized($message = 'Unauthorized!')
    {
        return $this->_generateErrorResponse($message, Status::UNAUTHORIZED);
    }

    protected function _generateForbidden($message = 'Forbidden!')
    {
        return $this->_generateErrorResponse($message, Status::FORBIDDEN);
    }

    protected function _generateException(\Exception $e)
    {
        return $this->_generateErrorResponse($e->getMessage(), $e->getCode());
    }

    protected function _getFriendList($user, array $fields = array('id', 'firstName', 'lastName', 'avatar')) {
        $friends = $user->getFriends();
        return $this->_getUserSummaryList($friends, $fields);
    }

    protected function _getUserSummaryList(array $userIds, array $fields = array('id', 'firstName', 'lastName', 'avatar'))
    {
        $userData = $this->userRepository->getAllByIds($userIds);

        $locationHelper = new \Helper\Location();
        $currentUser = $this->user;
        array_walk($userData, function(&$friend, $k, $fields) use($locationHelper, $currentUser) {

            if(in_array('distance', $fields)) $fields[] = 'currentLocation';

            $friend = array_intersect_key($friend, array_flip($fields));

            if(in_array('distance', $fields)) {
                $from = $currentUser->getCurrentLocation();
                $to = $friend['currentLocation'];

                $friend['distance'] = $locationHelper::distance($from['lat'], $from['lng'],$to['lat'],$to['lng']);
            }
        },$fields);

        return $userData;
    }

    private function setupGearman()
    {
        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient = new \GearmanClient();
            $this->gearmanClient->addServer($this->config['gearman']['host'], $this->config['gearman']['port']);
        }
    }

    protected function _sendPushNotification(array $userIds, $title, $objectType, $objectId = null, $validity = 0)
    {
        foreach ($userIds as $userId) {

            $this->addTask('send_push_notification', json_encode(array(
                'user_id' => $userId,
                'notification' => array(
                    'title' => $title,
                    'objectId' => $objectId,
                    'objectType' => $objectType,
                ),
                'timestamp' => time(),
                'validity' => $validity,
            )));
        }
    }

    protected function _validateURL($URL) {
            $v = "/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i";
            return (bool)preg_match($v, $URL);
    }

    protected function _isRequiredFieldsFound(array $required_fields, array $data) {
        $missing_fields = array();

        foreach ($required_fields as $key) {
            if (!isset($data[$key])) {
                $missing_fields[] = $key;
            }
        }

        if (!empty($missing_fields)) {
            $this->missingFields = $missing_fields;
            return false;
        }

        return true;
    }

    protected function _generateMissingFieldsError() {
        $fields_comma_joined = implode(", ", array_filter($this->missingFields));
        $is_or_are = (count($this->missingFields) > 1 ? 'are' : 'is');

        return $this->_generate500($fields_comma_joined . ' ' . $is_or_are . " required parameters.");
    }

}