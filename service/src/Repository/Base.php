<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\User as UserDocument;
use Monolog\Logger as Logger;
use Monolog\Handler\StreamHandler as StreamHandler;

class Base extends DocumentRepository {

    protected $loggerName = null;
    protected $logger;
    protected $loggerStreamHandler;

    /**
     * @var array
     */
    protected $config;

    /**
     * @var UserDocument
     */
    protected $currentUser;

    /**
     * @var \GearmanClient
     */
    protected $gearmanClient;

    public function setConfig($config) {
        $this->config = $config;
    }

    public function setCurrentUser($user) {
        $this->currentUser = $user;
    }

    private function setupGearman() {
        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient = new \GearmanClient();
            $this->gearmanClient->addServer($this->config['gearman']['host'], $this->config['gearman']['port']);
        }
    }

    public function addTask($eventName, $data) {
        if (!$this->gearmanClient) {
            $this->setupGearman();
        }

        if (class_exists('\\GearmanClient')) {
            $this->gearmanClient->doBackground($eventName, $data);
        }
    }

    public function getAll($limit = 20, $offset = 0) {
        return $this->findBy(array(), null, $limit, $offset);
    }

    public function getByUser(UserDocument $user) {
        $docs = $this->findBy(array('owner' => $user->getId()), array('createDate' => 'DESC'));
        return $this->_toArrayAll($docs);
    }

    public function insert($doc) {
        $valid = $doc->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid Location data', 406);
        }

        $this->dm->persist($doc);
        $this->dm->flush($doc);

        return $doc;
    }

    public function delete($id) {
        $doc = $this->find($id);

        if (is_null($doc)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($doc);
        $this->dm->flush();
    }

    protected function _toArrayAll($results) {
        $docsAsArr = array();
        foreach ($results as $place) {
            $docsAsArr[] = $place->toArray();
        }

        return $docsAsArr;
    }

    protected function _buildAbsoluteUrl($prefix, $suffix) {
        $http_prefixed = preg_match("/http:\/\//i", $suffix) ||
                         preg_match("/https:\/\//i", $suffix);

        if (empty($suffix)) {
            return null;
        } else if ($http_prefixed) {
            return $suffix;
        } else {
            return $prefix . $suffix;
        }
    }

    protected function _buildCoverPhotoUrl($data) {
        return $this->_buildAbsoluteUrl($this->config['web']['root'], $data['coverPhoto']);
    }

    protected function _buildAvatarUrl($data) {
        return $this->_buildAbsoluteUrl($this->config['web']['root'], $data['avatar']);
    }

    protected function _trimInvalidUsers($data) {
        $userRepo = $this->dm->getRepository('Document\User');
        $users = array();

        foreach ($data as $userId) {
            $user = $userRepo->find($userId);
            if ($user) array_push($users, $user->getId());
        }
        return $users;
    }

    public function refresh($document) {
        $this->dm->refresh($document);
    }

    protected function createLogger($name) {
        $this->logger = new Logger($name);
        $this->logger->pushHandler($this->getStreamHandler());

        return $this->logger;
    }

    protected function getLogger() {
        if ($this->logger)
            return $this->logger;
        else
            return $this->createLogger($this->loggerName);
    }

    protected function getStreamHandler() {
        if (is_null($this->loggerStreamHandler)) {
            $config = $this->config['logging'];
            $level = Logger::DEBUG;
            $file = "%s/logs/web_%s.log";

            if (isset($config['level']) && !empty($config['level']))
                $level = $this->decideLoggingLevel($config['level']);

            if (isset($config['file']) && !empty($config['file']))
                $file = $config['file'];

            $this->loggerStreamHandler =
                    new StreamHandler(sprintf($file, ROOTDIR . '/../', APPLICATION_ENV), $level);
        }

        return $this->loggerStreamHandler;
    }

    private function decideLoggingLevel($level) {
        switch (strtoupper($level)) {
            case 'DEBUG':
                return Logger::DEBUG;
            case 'WARN':
                return Logger::WARNING;
            case 'WARNING':
                return Logger::WARNING;
            case 'ERROR':
                return Logger::ERROR;
            case 'INFO':
                return Logger::INFO;
            case 'CRITICAL':
                return Logger::CRITICAL;
            case 'NOTICE':
                return Logger::NOTICE;

            default:
                return Logger::INFO;
        }
    }

    public function isLoggerEnabled() {
        return !empty($this->logger);
    }

    private function log($type, $msg) {
        if ($this->isLoggerEnabled()) {
            $this->logger->{
            $type
            }($msg);
        }
    }

    public function debug($msg) {
        $this->log('debug', $msg);
    }

    public function info($msg) {
        $this->log('info', $msg);
    }

    public function warn($msg) {
        $this->log('warn', $msg);
    }

    public function error($msg) {
        $this->log('err', $msg);
    }

    public function notice($msg) {
        $this->log('notice', $msg);
    }

    public function checkMemoryBefore() {
        $this->debug("Memory usage before: " . (memory_get_usage() / 1024) . " KB");
    }

    public function checkMemoryAfter() {
        $this->debug("Memory usage after: " . (memory_get_usage() / 1024) . " KB");
    }


}