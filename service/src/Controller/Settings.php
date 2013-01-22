<?php

namespace Controller;

use Symfony\Component\HttpFoundation\Response;
use Repository\UserRepo as UserRepository;
use Helper\Location;
use Helper\Status;
use Helper\ShareConstant;

/**
 * Manage user related settings
 */
class Settings extends Base {

    const ALLOWED_DISTANCE = 100; # Meters

    public function init() {
        parent::init();

        $this->userRepository = $this->dm->getRepository('Document\User');
        $this->_updatePulse();
        $this->userRepository->setCurrentUser($this->user);
        $this->userRepository->setConfig($this->config);

        $this->_ensureLoggedIn();
        $this->createLogger('Controller::Settings');
    }

    /**
     * PUT /settings/share/location
     * GET /settings/share/location
     *
     * Store location sharing related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function location() {
        $data = $this->request->request->all();
        $settings = $this->user->getLocationSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $settings = array_merge($settings, $data);
        $this->user->setLocationSettings($settings);

        if ($settings['status'] == 'off') {
            $this->user->setVisible(false);
        } else {
            $this->user->setVisible(true);
        }

        $this->persistAndReturn($settings);
        $this->requestForCacheUpdate($this->user);

        return $this->response;
    }

    /**
     * PUT /settings/geo_fence
     * PUT /settings/geo_fence
     *
     * Store geo fence related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function geoFence() {
        $data = $this->request->request->all();
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
     * Store notification related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function notifications() {
        $data = $this->request->request->all();
        $settings = $this->user->getNotificationSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->_generateResponse(array('result' => $settings));
        }

        $options = array_keys($settings);

        foreach ($options as $opt) {

            if ($opt != 'proximity_radius') {

                if (isset($data[$opt . '_sm'])) {
                    $settings[$opt]['sm'] = (boolean)$data[$opt . '_sm'];
                }

                if (isset($data[$opt . '_mail'])) {
                    $settings[$opt]['mail'] = (boolean)$data[$opt . '_mail'];
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
     * Store platforms related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function platforms() {
        $data = $this->request->request->all();
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
     * Store layers related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function layers() {
        $data = $this->request->request->all();
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
     * Store push notification related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function push() {
        $data = $this->request->request->all();
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
     * Store account settings related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function accountSettings() {
        $data = $this->request->request->all();
        if (!empty($data['email'])) {
            $data['email'] = strtolower($data['email']);
        }

        if ($this->request->getMethod() == 'GET') {
            $data = $this->user->toArrayDetailed();
            $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
            $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);
            return $this->_generateResponse(array('result' => $data));
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
        $data['avatar'] = \Helper\Url::buildAvatarUrl($data);
        $data['coverPhoto'] = \Helper\Url::buildCoverPhotoUrl($data);

        return $this->_generateResponse($data);
    }

    /**
     * PUT /settings/sharing_preference_settings
     *
     * Store location sharing related preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function sharingPreference() {
        $data = $this->request->request->all();
        $settings = $this->user->getSharingPreferenceSettings();

        if ($this->request->getMethod() == 'GET') {
            return $this->returnResponse($settings);
        }

        $settings = array_merge($settings, $data);
        $this->user->setSharingPreferenceSettings($settings);

        return $this->persistAndReturn($settings);
    }

    /**
     * PUT /settings/sharing_privacy_mode
     *
     * Store location sharing privacy mode
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function sharingPrivacyMode() {
        $data = $this->request->request->all();
        try {
            $sharableFields = array('shareLocation', 'shareProfilePicture', 'shareNewsFeed');
            $minValue = 1;
            $maxValue = 5;
            $changed = false;

            foreach ($sharableFields as $field) {
                if (!empty($data[$field]) && ((int) $data[$field]) >= $minValue && ((int) $data[$field]) <= $maxValue) {
                    $this->user->{'set' . ucfirst($field)}($data[$field]);
                    $changed = true;
                }
            }

            if ($changed) {
                $this->persistAndReturn(array($data));
                $this->requestForCacheUpdate($this->user);
                return $this->response;
            }

            return $this->_generateErrorResponse('Any of these fields - ' . implode(', ', $sharableFields) . ' is set.');

        } catch (\Exception\ResourceNotFoundException $e) {

            return $this->_generate404();

        } catch (\Exception\UnauthorizedException $e) {

            return $this->_generateUnauthorized($e->getMessage());

        } catch (\Exception $e) {

            return $this->_generateException($e);
        }
    }

    /**
     * PUT /current-location
     *
     * Store user's current location
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function currentLocation() {
        $data = $this->request->request->all();

        $oldLocation = $this->user->getCurrentLocation();

        if ($this->request->getMethod() == 'GET') {
            $this->debug('Returning current location');
            return $this->returnResponse($oldLocation);
        }

        if (array_key_exists('lat', $data) && array_key_exists('lng', $data)) {

            $newLocation['lat'] = floatval($data['lat']);
            $newLocation['lng'] = floatval($data['lng']);

            $this->debug('Updating current location');
            $this->user->setCurrentLocation($newLocation);
            $this->_updateVisibility($this->user);
            $this->persistOnly();

            // Update additional information
            try {
                $this->_updateLastSeenAt($this->user);

                if ($this->hasMovedAway($oldLocation, $newLocation)) {
                    $this->debug('User has moved far away');
                    $this->_sendProximityAlerts($this->user);
                    $this->requestForCacheUpdate($this->user, $oldLocation, $newLocation);
                } else {
                    $this->debug('User has not moved 500m away');
                }

            } catch (\Exception $e) {
                $this->error($e->getMessage());
            }

            return $this->persistAndReturn($newLocation, true);

        } else {

            $this->response->setContent(
                json_encode(array('message' => 'Invalid location (lat and lng required)')));
            $this->response->setStatusCode(417);

            return $this->response;
        }
    }

    private function hasMovedAway($oldLocation, $newLocation) {
        $distance = \Helper\Location::distance(
            $oldLocation['lat'], $oldLocation['lng'],
            $newLocation['lat'], $newLocation['lng']); # Meter

        return $distance > self::ALLOWED_DISTANCE;
    }

    /*
     * Update users visibility based on geo-fence settings and current location
     */
    private function _updateVisibility(\Document\User $user) {
        $fnc = $user->getGeoFence();

        if ($fnc['radius'] > 0) {
            $loc = $user->getCurrentLocation();

            $distance = \Helper\Location::distance($loc['lat'], $loc['lng'], $fnc['lat'], $fnc['lng']);
            $user->setVisible(($distance > $fnc['radius']));
        }

    }

    /*
     * Update the address user currently at
     */
    private function _updateLastSeenAt(\Document\User $user) {
        $this->debug('Requesting for address update');
        $this->addTask(\Helper\Constants::APN_UPDATE_LAST_SEEN_AT,
                       json_encode(array('user_id' => $user->getId())));
    }

    private function persistAndReturn($result, $already_persisted = false) {
        if (!$already_persisted) {
            $this->user->setUpdateDate(new \DateTime());
            $this->dm->persist($this->user);
            $this->dm->flush();
        }

        return $this->_generateResponse(array('result' => $result));
    }

    private function persistOnly() {
        $this->user->setUpdateDate(new \DateTime());
        $this->dm->persist($this->user);
        $this->dm->flush();
    }

    private function _sendProximityAlerts(\Document\User $user) {
        $this->debug('Sending proximity alert');
        $this->addTask(\Helper\Constants::APN_PROXIMITY_ALERT,
                       json_encode(array(
                                        'reqId' => time() * rand(0, 500),
                                        'user_id' => $user->getId(),
                                        'timestamp' => time(),
                                        'validity' => 7200, // 2 hours
                                   )));
    }

    private function returnResponse($result) {
        return $this->_generateResponse(array('result' => $result));
    }

    /**
     * GET /settings/all
     *
     * Retrieve user's all preferences
     *
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function getAll() {
        $location = $this->user->getLocationSettings();
        $geoFence = $this->user->getGeoFence();
        $notification = $this->user->getNotificationSettings();
        $platform = $this->user->getPlatformSettings();
        $layers = $this->user->getLayersSettings();
        $account = $this->user->toArrayDetailed();
        $sharingPreference = $this->user->getSharingPreferenceSettings();
        $shareLocation = $this->user->getShareLocation();
        $shareProfilePicture = $this->user->getShareProfilePicture();
        $shareNewsFeed = $this->user->getShareNewsFeed();
        $currentLocation = $this->user->getCurrentLocation();

        $this->response->setContent(
            json_encode(array(
                             'location' => $location,
                             'geoFence' => $geoFence,
                             'notification' => $notification,
                             'platform' => $platform,
                             'layers' => $layers,
                             'account' => $account,
                             'sharingPreference' => $sharingPreference,
                             'shareLocation' => $shareLocation,
                             'shareProfilePicture' => $shareProfilePicture,
                             'shareNewsFeed' => $shareNewsFeed,
                             'currentLocation' => $currentLocation
                        )));
        $this->response->setStatusCode(Status::OK);

        return $this->response;

    }
}