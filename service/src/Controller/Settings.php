<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;
use Helper\Location;
use Helper\Status;

class Settings extends Base
{

    /**
     * Initialize the controller.
     */
    public function init()
    {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
    }

    /**
     * PUT /settings/share/location
     * GET /settings/share/location
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function location()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getLocationSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));;
        }

        $settings = array_merge($settings, $data);
        $this->user->setLocationSettings($settings);

        if ($settings['status'] == 'off') {
            $this->user->setVisible(false);
        } else {
            $this->user->setVisible(true);
        }

        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/geo_fence
     * PUT /settings/geo_fence
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function geoFence()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getGeoFence();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
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

        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/notifications
     * GET /settings/notifications
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function notifications()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getNotificationSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $options = array_keys($settings);

        foreach ($options as $opt) {

            if ($opt != 'proximity_radius') {

                if (isset($data[$opt . '_sm'])) {
                    $settings[$opt]['sm'] = (boolean) $data[$opt . '_sm'];
                }

                if (isset($data[$opt . '_mail'])) {
                    $settings[$opt]['mail'] = (boolean) $data[$opt . '_mail'];
                }
            } else {
                $settings[$opt] = $data[$opt];
            }

        }

        $this->user->setNotificationSettings($settings);
        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/platforms
     * GET /settings/platforms
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function platforms()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getPlatformSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt]))
                $settings[$opt] = (boolean)$data[$opt];
        }

        $this->user->setPlatformSettings($settings);
        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/layers
     * GET /settings/layers
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function layers()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getLayersSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt]))
                $settings[$opt] = (boolean)$data[$opt];
        }

        $this->user->setLayersSettings($settings);
        return $this->persistAndReturn($settings);
    }

    /**
     * GET /settings/push
     * PUT /settings/push
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function push()
    {
        $data     = $this->request->request->all();
        $settings = $this->user->getPushSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $options = array_keys($settings);
        foreach ($options as $opt) {
            if (isset($data[$opt]))
                $settings[$opt] = $data[$opt];
        }

        $this->user->setPushSettings($settings);
        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/account_settings
     * GET /settings/account_settings
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function accountSettings()
    {
        $data = $this->request->request->all();
        if(!empty($data['email'])){
            $data['email'] = strtolower($data['email']);
        }

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $this->user->toArrayDetailed()));
        }

        try {

            $user = $this->userRepository->updateAccountSettings($data);

            if (!empty($data['avatar'])) {
                $this->userRepository->saveAvatarImage($user->getId(), $data['avatar']);
            }

            if (!empty($data['coverPhoto'])) {
                $user = $this->userRepository->saveCoverPhoto($user->getId(), $data['coverPhoto']);
            }

        } catch (\Exception\ResourceNotFoundException $e) {

            return $this->_generate404();

        } catch (\Exception\UnauthorizedException $e) {

            return $this->_generateUnauthorized($e->getMessage());

        } catch (\Exception $e) {

            return $this->_generateException($e);
        }

        $data = $user->toArrayDetailed();
        $data['avatar'] = $this->config['web']['root']. $data['avatar'];
        $data['coverPhoto'] = $this->config['web']['root']. $data['coverPhoto'];

        return $this->_generateResponse($data);
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
            return $this->returnResponse($settings);
        }

        $settings = array_merge($settings, $data);
        $this->user->setSharingPreferenceSettings($settings);

        return $this->persistAndReturn( $settings);
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
            return $this->returnResponse($location);
        }

        if (array_key_exists('lat', $data) && array_key_exists('lng', $data)) {

            $location['lat'] = floatval($data['lat']);
            $location['lng'] = floatval($data['lng']);

            $this->user->setCurrentLocation($location);

            $this->_updateVisibility($this->user);

            // Update additional information
            try {
                // TODO: Use background job for _updateLastSeenAt
                $this->_updateLastSeenAt($this->user);
                $this->_sendProximityAlerts($this->user);
            } catch (\Exception $e) {
                // Do the location update even if
                return $this->persistAndReturn($location);
            }

            return $this->persistAndReturn($location);

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

    /**
     * Update the address user currently at
     *
     * @param \Document\User $user
     *
     */
    private function _updateLastSeenAt(\Document\User $user)
    {
        $reverseGeo = new \Service\Geolocation\Reverse($this->config['googlePlace']['apiKey']);

        $address = $reverseGeo->getAddress($user->getCurrentLocation());
        $user->setLastSeenAt($address);
    }

    private function persistAndReturn($result)
    {
        $this->user->setUpdateDate(new \DateTime());
        $this->dm->persist($this->user);
        $this->dm->flush();

        return $this->_generateResponse(array('result' => $result));
    }

    private function _sendProximityAlerts(\Document\User $user)
    {
        $this->addTask('proximity_alert', json_encode(array('user_id' => $user->getId())));
    }

    private function returnResponse($result)
    {
        return $this->_generateResponse(array('result' => $result));
    }

    /**
     * GET /settings/all
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getAll()
    {
        $location          = $this->user->getLocationSettings();
        $geoFence          = $this->user->getGeoFence();
        $notification      = $this->user->getNotificationSettings();
        $platform          = $this->user->getPlatformSettings();
        $layers            = $this->user->getLayersSettings();
        $account           = $this->user->toArrayDetailed();
        $sharingPreference = $this->user->getSharingPreferenceSettings();
        $currentLocation   = $this->user->getCurrentLocation();

        $this->response->setContent(json_encode(array(
                                                    'location'          => $location,
                                                    'geoFence'          => $geoFence,
                                                    'notification'      => $notification,
                                                    'platform'          => $platform,
                                                    'layers'            => $layers,
                                                    'account'           => $account,
                                                    'sharingPreference' => $sharingPreference,
                                                    'currentLocation'   => $currentLocation
                                                )));
        $this->response->setStatusCode(Status::OK);

        return $this->response;

    }
}