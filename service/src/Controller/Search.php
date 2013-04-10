<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;

use Repository\UserRepo as UserRepository;
use Repository\ExternalUserRepo as ExtUserRepo;
use Helper\Location;
use Helper\Status;
use Service\Search\ApplicationSearchFactory as ApplicationSearchFactory;

/**
 * Perform search on users, places and external users
 */
class Search extends Base
{
    /**
     * Maximum allowed older checkins to show in the list.
     */
    const MAX_ALLOWED_OLDER_CHECKINS = '12 hours ago';

    private $extUserRepo;

    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->extUserRepo = $this->dm->getRepository('Document\ExternalUser');

        $this->createLogger('Controller::Search');
        $this->_ensureLoggedIn();
    }

    /**
     * POST /search
     *
     * Retrieve people, places and external users from the given location.
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function all()
    {
        $this->debug('Preparing search result');
        $data = $this->request->request->all();

        if ($this->_isRequiredFieldsFound(array('lat', 'lng'), $data)) {
            $this->userRepository->updateUserPulse($this->user);

            return $this->_generateResponse($this->performSearch($data));
        } else {
            $this->warn('Invalid request with missing required fields');
            return $this->_generateMissingFieldsError();
        }
    }

    protected function performSearch($data)
    {
        $this->debug('No cache found, Creating cache search cache');
        $appSearch = ApplicationSearchFactory::getInstance(
            ApplicationSearchFactory::AS_DEFAULT, $this->user, $this->dm, $this->config);

        return $appSearch->searchAll(
            $data, array('user' => $this->user, 'limit' => \Helper\Constants::PEOPLE_LIMIT));
    }

    /**
     * GET /search/people
     *
     * Retrieve all people from the specific location
     */
    public function allPeopleList()
    {
        $data = $this->request->request->all();
        $appSearch = ApplicationSearchFactory::
            getInstance(ApplicationSearchFactory::AS_DEFAULT,
            $this->user, $this->dm, $this->config);

        return $this->_generateResponse(
            $appSearch->searchPeople($data, array('limit' => \Helper\Constants::PEOPLE_LIMIT)));
    }

    /** TODO: Finalize deals search */
    protected function deals($data)
    {
        return array();
    }

    /**
     * POST /search/keyword
     *
     * Retrieve people, places and external users from the given location.
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function byKeyword()
    {
        $this->debug('Preparing search result');
        $data = $this->request->request->all();

        if ($this->_isRequiredFieldsFound(array('lat', 'lng'), $data)) {
            $this->userRepository->updateUserPulse($this->user);

            return $this->_generateResponse($this->performSearch($data));
        } else {
            $this->warn('Invalid request with missing required fields');
            return $this->_generateMissingFieldsError();
        }
    }
}