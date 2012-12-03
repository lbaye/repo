<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as UserRepository;
use Repository\ExternalUserRepo as ExtUserRepo;
use Helper\Location;
use Helper\Status;
use Service\Search\ApplicationSearchFactory as ApplicationSearchFactory;

class Search extends Base {
    /**
     * Maximum allowed older checkins to show in the list.
     */
    const MAX_ALLOWED_OLDER_CHECKINS = '12 hours ago';

    private $extUserRepo;

    /**
     * Initialize the controller.
     */
    public function init() {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->extUserRepo = $this->dm->getRepository('Document\ExternalUser');

        $this->createLogger('Controller::Search');
        $this->_ensureLoggedIn();
    }

    public function all() {
        $this->debug('Preparing search result');
        $data = $this->request->request->all();

        if ($this->_isRequiredFieldsFound(array('lat', 'lng'), $data)) {
            $this->updateUserPulse($this->user);
            return $this->cacheAndReturn(
                \Helper\CacheUtil::buildSearchCachePath($this->user, $data), 'performSearch', $data);
        } else {
            $this->warn('Invalid request with missing required fields');
            return $this->_generateMissingFieldsError();
        }
    }

    protected function performSearch($data) {
        $appSearch = ApplicationSearchFactory::getInstance(
            ApplicationSearchFactory::AS_DEFAULT, $this->user, $this->dm, $this->config);

        return $appSearch->searchAll($data, array('limit' => \Helper\Constants::PEOPLE_LIMIT));
    }

    public function allPeopleList() {
        $data = $this->request->request->all();
        $appSearch = ApplicationSearchFactory::
                getInstance(ApplicationSearchFactory::AS_DEFAULT,
                            $this->user, $this->dm, $this->config);

        return $this->_generateResponse(
            $appSearch->searchPeople($data, array('limit' => \Helper\Constants::PEOPLE_LIMIT)));
    }

    private function updateUserPulse(\Document\User $user) {
        if (!$user->isOnlineUser()) {
            $user->setLastPulse(new \DateTime());
            $this->userRepository->updateObject($user);
        }
    }

    /** TODO: Finalize deals search */
    protected function deals($data) {
        return array();
    }
}