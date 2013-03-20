<?php

namespace Controller;

use Monolog\Logger as Logger,
Monolog\Handler\StreamHandler as StreamHandler,
Symfony\Component\HttpFoundation\Request,
Symfony\Component\HttpFoundation\Response,
Doctrine\ODM\MongoDB\DocumentManager;

use Repository\UserRepo as userRepository;

use Helper\Status;
use Helper\ShareConstant;

/**
 * Base controller class for providing basic and reusable methods across all controllers.
 * @abstract
 * @ignore
 */
abstract class Base
{

    /**
     * Default response content type
     */
    const DEFAULT_CONTENT_TYPE = 'json';
    const CONTENT_TYPE_HTML = 'html';

    protected $logger;
    protected $loggerStreamHandler;

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
     * @var \MtHaml\Environment
     */
    private $hamlEnvironment;

    private $cacheRefRepo;

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
            $this->user = $this->dm
                ->getRepository('Document\User')
                ->getByAuthToken($this->request->headers->get('Auth-Token'));

        } elseif ($this->request->query->has('authToken')) {
            $this->user = $this->dm
                ->getRepository('Document\User')
                ->getByAuthToken($this->request->query->get('authToken'));

        } elseif ($this->request->headers->has('X-AuthGen')) {
            $this->user = $this->dm
                ->getRepository('Document\User')
                ->find($this->request->headers->get('X-AuthGen'));
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

    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->serializer = \Service\Serializer\Factory::getSerializer('json');
        $this->cacheRefRepo = $this->dm->getRepository('Document\CacheRef');
    }

    protected function createLogger($name)
    {
        $this->logger = new Logger($name);
        $this->logger->pushHandler($this->getStreamHandler());

        return $this->logger;
    }

    protected function getStreamHandler()
    {
        if (is_null($this->loggerStreamHandler))
            $this->loggerStreamHandler = \Helper\Util::getStreamHandler($this->config);

        return $this->loggerStreamHandler;
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

        foreach ($documents as $doc) {
            if ($doc->isPermittedFor($this->user)) {
                $permittedDocs[] = $doc;
            }
        }

        return $permittedDocs;
    }

    protected function _filterByPermissionForBothUsers($documents, $getUserObjs)
    {
        $permittedDocs = array();

        foreach ($documents as $doc) {
            if ($doc->isPermittedFor($getUserObjs)) {
                if ($doc->isPermittedFor($this->user)) {
                    $permittedDocs[] = $doc;
                }
            }
        }

        return $permittedDocs;
    }

    protected function _filterByPermissionForDetails($documents, $userObj)
    {

        $permittedDocs = array();
        foreach ($documents as $doc) {
            if ($doc->isPermittedPhotos($userObj)) {
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

    public function _generateResponse($hash, $code = Status::OK, $options = array())
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
        return $this->_generateResponse(array('message' => $message), $code);
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

    protected function _getFriendList(\Document\User $user, array $fields = array('id', 'firstName', 'lastName', 'avatar'))
    {
        $friends = $user->getFriends();
        if (!empty($friends))
            return $this->_getUserSummaryList($friends, $fields);
        else
            return array();
    }

    protected function _getUserSummaryList(
        array $userIds, array $fields = array('id', 'username', 'firstName', 'lastName', 'avatar'))
    {

        $userData = $this->userRepository->getAllByIds($userIds);

        $locationHelper = new \Helper\Location();
        $currentUser = $this->user;
        array_walk($userData, function(&$friend, $k, $fields) use($locationHelper, $currentUser)
        {

            if (in_array('distance', $fields)) $fields[] = 'currentLocation';

            $friend = array_intersect_key($friend, array_flip($fields));

            if (in_array('distance', $fields)) {
                $from = $currentUser->getCurrentLocation();
                $to = $friend['currentLocation'];

                $friend['distance'] = $locationHelper::distance($from['lat'], $from['lng'], $to['lat'], $to['lng']);
            }
        }, $fields);

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
            $this->addTask('send_push_notification',
                json_encode(array(
                    'user_id' => $userId,
                    'notification' => array(
                        'title' => $title,
                        'objectId' => $objectId,
                        'objectType' => $objectType,
                        'receiverId' => $userId,
                    ),
                    'timestamp' => time(),
                    'validity' => $validity,
                )));
        }
    }

    protected function _validateURL($URL)
    {
        $v = "/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i";
        return (bool)preg_match($v, $URL);
    }

    protected function _isRequiredFieldsFound(array $required_fields, array $data)
    {
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

    protected function _generateMissingFieldsError()
    {
        $fields_comma_joined = implode(", ", array_filter($this->missingFields));
        $is_or_are = (count($this->missingFields) > 1 ? 'are' : 'is');

        return $this->_generate500($fields_comma_joined . ' ' . $is_or_are . " required parameters.");
    }

    public function isLoggerEnabled()
    {
        return !empty($this->logger);
    }

    private function log($type, $msg)
    {
        if ($this->isLoggerEnabled()) {
            $this->logger->{
            $type
            }($msg);
        }
    }

    public function debug($msg)
    {
        $this->log('debug', $msg);
    }

    public function info($msg)
    {
        $this->log('info', $msg);
    }

    public function warn($msg)
    {
        $this->log('warn', $msg);
    }

    public function error($msg)
    {
        $this->log('err', $msg);
    }

    public function notice($msg)
    {
        $this->log('notice', $msg);
    }

    public function checkMemoryBefore()
    {
        $this->debug("Memory usage before: " . (memory_get_usage() / 1024) . " KB");
    }

    public function checkMemoryAfter()
    {
        $this->debug("Memory usage after: " . (memory_get_usage() / 1024) . " KB");
    }

    public function getHamlEnvironment()
    {
        if ($this->hamlEnvironment == null)
            $this->hamlEnvironment = new \MtHaml\Environment('php');

        return $this->hamlEnvironment;
    }

    /**
     * Render HAML based HTML view
     *
     * @param array $vars
     * @param string $templateFile
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function render($vars = array(), $templateFile = null)
    {
        if (empty($templateFile))
            $templateFile = $this->getTemplateFile(debug_backtrace());

        return $this->renderTemplate($vars, $templateFile);
    }

    private function renderTemplate($vars, $templateFile)
    {
        $this->response->setContent($this->generateContent($vars, $templateFile));
        $this->response->setStatusCode(Status::OK);
        $this->response->headers->set('Content-Type', 'text/html');

        return $this->response;
    }

    private function generateContent($vars, $templateFile)
    {
        $fileNameParts = explode(DIRECTORY_SEPARATOR, $templateFile);
        $fileName = $fileNameParts[count($fileNameParts) - 1];

        $cacheFile = implode(DIRECTORY_SEPARATOR, array(ROOTDIR, '..', 'app', 'cache', $fileName));
        $cacheDir = implode(DIRECTORY_SEPARATOR, array(ROOTDIR, '..', 'app', 'cache'));

        $this->convertHamlToPhpTemplate($cacheFile, $templateFile);

        $loader = new \Symfony\Component\Templating\Loader\FilesystemLoader($cacheDir . '/%name%');
        $view = new \Symfony\Component\Templating\PhpEngine(
            new \Symfony\Component\Templating\TemplateNameParser(), $loader);

        $vars = array_merge(
            $vars, array(
            'baseUrl' => \Helper\Dependencies::$rootUrl,
            'userRepo' => $this->userRepository,
            'baseDir' => ROOTDIR,
        ));

        return $view->render($fileName, $vars);
    }

    private function convertHamlToPhpTemplate($cacheFile, $templateFile)
    {
        if (!file_exists($cacheFile) || $this->templateCacheHasExpired($cacheFile, $templateFile)) {
            $compiled = $this->getHamlEnvironment()
                ->compileString(file_get_contents($templateFile), $templateFile);
            file_put_contents($cacheFile, $compiled);
        }
    }

    private function templateCacheHasExpired($cacheFile, $templateFile)
    {
        return filemtime($templateFile) > filemtime($cacheFile);
    }

    private function getTemplateFile($trace)
    {
        array_shift($trace);
        $caller = $trace[0];

        return implode(
            DIRECTORY_SEPARATOR,
            array(ROOTDIR, '..', 'src', 'Views',
                $this->simplifyControllerName(get_class($caller['object'])),
                $caller['function'])) . '.haml';
    }

    private function simplifyControllerName($name)
    {
        $parts = explode('\\', $name);
        return $parts[count($parts) - 1];
    }

    /**
     * Cache generated response.
     *
     * @param  $cachePath - File where cache will be stored
     * @param  $funcName - Function which will be invoked to generate the response
     * @param  $params - http parameters
     * @return \Symfony\Component\HttpFoundation\Response
     */
    protected function cacheAndReturn(&$cachePath, $funcName, $params)
    {
        if (\Helper\CacheUtil::hasExpired($cachePath)) {
            $this->cacheAndBuildResponse($cachePath, $funcName, $params);
            return $this->response;
        } else {
            return $this->buildResponseFromCache($cachePath);
        }
    }

    private function buildResponseFromCache(&$cachePath)
    {
        $this->response->setContent(file_get_contents($cachePath));
        $this->response->setStatusCode(Status::OK);

        return $this->response;
    }

    protected function cacheAndBuildResponse(&$cachePath, &$funcName, &$params)
    {
        $results = $this->$funcName($params);
        \Helper\CacheUtil::createCacheReference(
            $this->cacheRefRepo, $this->user, $cachePath, $params, $results['people']);

        \Helper\CacheUtil::ensureDirectoryExistence($cachePath);
        $this->_generateResponse($results);
        file_put_contents($cachePath, $this->response->getContent());

        return $this->response;
    }

    protected function requestForCacheUpdate(\Document\User $user, $oldLocation = null, $newLocation = null)
    {
        $this->debug('Requesting for cache update');
        $this->addTask(
            \Helper\Constants::APN_REFRESH_SEARCH_CACHE,
            json_encode(array(
                'userId' => $user->getId(),
                'oldLocation' => $oldLocation,
                'newLocation' => $newLocation
            )));
    }

    /*
    * Update user pulse
    */
    protected function _updatePulse()
    {
        if (isset($this->user) && $this->user instanceof \Document\User) {
            $this->userRepository->updateUserPulse($this->user);
        }
    }
}