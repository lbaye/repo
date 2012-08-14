<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\User as UserRepository;
use Helper\Location;

class Settings extends Base
{
    /**
     * @var UserRepository
     */
    private $userRepository;

    /**
     * Initialize the controller.
     */
    public function init()
    {
        $this->response = new Response();
        $this->response->headers->set('Content-Type', 'application/json');

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);

        $this->_ensureLoggedIn();
    }

    /**
     * PUT /settings/share/location/{with}
     *
     * @param $with
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function location($with)
    {
        if (!in_array($with, array('friends', 'strangers'))) {

            $this->response->setContent(json_encode(array('result' => 'Nothing to set for ' . $with)));
            $this->response->setStatusCode(404);

            return $this->response;
        } else {

            $data = $this->request->request->all();
            $settings = $this->user->getLocationSettings();

            if (empty($data['enabled'])) {
                $settings[$with] = false;
            } elseif ($data['enabled'] == '1') {
                $settings[$with] = true;
                if (isset($data['users'])) {
                    // @TODO: check if real users
                    // $users = $this->userRepository->getAllByIds(explode(',', $data['users']));

                    $settings['permitted_users'] = explode(',', $data['users']);
//                    foreach($users as $user) {
//                        $settings['permitted_users'][] = $user->getId();
//                    }
//                    \Doctrine\Common\Util\Debug::dump($settings, 3); die;
                }
                if (isset($data['circles'])) {
                    $settings['permitted_circles'] = explode(',', $data['circles']);
                }
                if (isset($data['max_time'])) {
                    $settings['max_time'] = intval($data['max_time']);
                }
            }

            $this->user->setLocationSettings($settings);
            return $this->_persistAndReturn($settings);
        }

    }

    /**
     * PUT /settings/geo_fence
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function geoFence()
    {
        $data = $this->request->request->all();
        $settings = $this->user->getGeoFence();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($settings);
        }

        if (isset($data['lat'])) {
            $settings['lat'] = floatval($data['lat']);
            $settings['lng'] = floatval($data['lng']);
        }
        if (isset($data['radius'])) {
            $settings['radius'] = intval($data['radius']);
        }

        $this->user->setGeoFence($settings);
        $this->_updateVisibility($this->user);

        return $this->_persistAndReturn($settings);
    }

    /**
     * PUT /settings/notifications
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function notifications()
    {
        $data = $this->request->request->all();
        $settings = $this->user->getNotificationSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($settings);
        }
        ;

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt . '_sm'])) $settings[$opt]['sm'] = (boolean)$data[$opt . '_sm'];
            if (isset($data[$opt . '_mail'])) $settings[$opt]['mail'] = (boolean)$data[$opt . '_mail'];
        }

        $this->user->setNotificationSettings($settings);
        return $this->_persistAndReturn($settings);
    }

    /**
     * PUT /settings/platforms
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function platforms()
    {
        $data = $this->request->request->all();
        $settings = $this->user->getPlatformSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($settings);
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt])) $settings[$opt] = (boolean)$data[$opt];
        }

        $this->user->setPlatformSettings($settings);
        return $this->_persistAndReturn($settings);
    }

    /**
     * PUT /settings/layers
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function layers()
    {
        $data = $this->request->request->all();
        $settings = $this->user->getLayersSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($settings);
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt])) $settings[$opt] = (boolean)$data[$opt];
        }

        $this->user->setLayersSettings($settings);
        return $this->_persistAndReturn($settings);
    }

    /**
     * PUT /settings/account_settings
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function accountSettings()
    {
        $data = $this->request->request->all();

        if ($this->request->getMethod() == 'GET')
        {
            return $this->_return($this->user->toArrayDetailed());
        }

        try {

            $user = $this->userRepository->updateAccountSettings($data);
            if (!empty($data['avatar']))
            {
                $this->userRepository->saveAvatarImage($user->getId(),$data['avatar']);
            }
            $this->response->setContent(json_encode($user->toArrayDetailed()));
            $this->response->setStatusCode(200);

        } catch (\Exception\ResourceNotFoundException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception\UnauthorizedException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());

        } catch (\Exception\ResourceAlreadyExistsException $e) {

            $this->response->setContent(json_encode(array('result' => $e->getMessage())));
            $this->response->setStatusCode($e->getCode());
        }

        return $this->response;
    }


    /**
     * PUT /settings/sharing_preference_settings
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function sharingPreference()
    {
        $data = $this->request->request->all();
        $settings = $this->user->getSharingPreferenceSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($settings);
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt . '_friends'])) $settings[$opt]['friends'] = (boolean)$data[$opt . '_friends'];
            if (isset($data[$opt . '_strangers'])) $settings[$opt]['strangers'] = (boolean)$data[$opt . '_strangers'];
            if (isset($data[$opt . '_public'])) $settings[$opt]['public'] = (boolean)$data[$opt . '_public'];
            if (isset($data[$opt . '_family'])) $settings[$opt]['family'] = (boolean)$data[$opt . '_family'];
        }

        $this->user->getSharingPreferenceSettings($settings);
        return $this->_persistAndReturn($settings);
    }

    /**
     * PUT /current-location
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function currentLocation()
    {
        $data = $this->request->request->all();

        $location = $this->user->getCurrentLocation();

        if ($this->request->getMethod() == 'GET') {
            return $this->_return($location);
        }

        if (array_key_exists('lat', $data) && array_key_exists('lng', $data)) {

            $location['lat'] = floatval($data['lat']);
            $location['lng'] = floatval($data['lng']);

            $this->user->setCurrentLocation($location);
            $this->_updateVisibility($this->user);

            return $this->_persistAndReturn($location);
        } else {

            $this->response->setContent(json_encode(array('message' => 'Invalid location (lat and lng required)')));
            $this->response->setStatusCode(417);

            return $this->response;
        }
    }

    /**
     * Update users visibility based on geo-fence settings and current location
     *
     * @param \Document\User $user
     *
     */
    private function _updateVisibility(\Document\User $user)
    {
        $fnc = $user->getGeoFence();

        if ($fnc['radius'] > 0) {
            $loc = $user->getCurrentLocation();

            $distance = \Helper\Location::distance($loc['lat'], $loc['lng'], $fnc['lat'], $fnc['lng']);
            $user->setVisible(($distance > $fnc['radius']));
        }

    }

    private function _persistAndReturn($result)
    {
        $this->dm->persist($this->user);
        $this->dm->flush();

        return $this->_return($result);
    }

    private function _return($result)
    {
        $this->response->setContent(json_encode(array('result' => $result)));
        $this->response->setStatusCode(200);

        return $this->response;
    }

    /**
     * GET /settings/all
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */

    public function getAll()
    {
        $location           = $this->user->getLocationSettings();
        $geoFence           = $this->user->getGeoFence();
        $notification       = $this->user->getNotificationSettings();
        $platform           = $this->user->getPlatformSettings();
        $layers             = $this->user->getLayersSettings();
        $account            = $this->user->toArrayDetailed();
        $sharingPreference  = $this->user->getSharingPreferenceSettings();
        $currentLocation    = $this->user->getCurrentLocation();

        $this->response->setContent(json_encode(array('location'          => $location,
                                                      'geoFence'          => $geoFence,
                                                      'notification'      => $notification,
                                                      'platform'         => $platform,
                                                      'layers'            => $layers,
                                                      'account'           => $account,
                                                      'sharingPreference' => $sharingPreference,
                                                      'currentLocation'   => $currentLocation )));
        $this->response->setStatusCode(200);

        return $this->response;

    }
}