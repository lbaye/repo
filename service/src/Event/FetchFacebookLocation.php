<?php

namespace Event;

use Repository\ExternalLocation as ExternalLocationRepository;

class FetchFacebookLocation extends Base
{
    /**
     * @var ExternalLocationRepository
     */
    protected $externalLocationRepository;

    protected function setFunction()
    {
        $this->function = 'fetch_facebook_location';
    }

    public function run(\GearmanJob $job)
    {
        $workload = json_decode($job->workload());
        $this->externalLocationRepository = $this->services['dm']->getRepository('Document\ExternalLocation');

        echo "Fetching friend location information for facebook user: ", $workload->facebookId, PHP_EOL;

        $facebook = new \Service\Location\Facebook();
        $locations = $facebook->getFriendLocation($workload->facebookId, $workload->facebookAuthToken);

        if (count($locations) > 0) {

            foreach ($locations['data'] as $location) {

                $location['source'] = 'fb-public';
                $location['profile'] = $facebook->getPublicProfile($location['author_uid']);
                $location['avatar'] = $facebook->getPublicAvatar($location['author_uid']);
                $location['coords'] = array('longitude' => $location['coords']['longitude'], 'latitude' => $location['coords']['latitude']);

                $savedLocation = $this->externalLocationRepository->insertFromFacebook($location);

                if ($savedLocation) {
                    echo "Added location with ID: ", $savedLocation->getRefId(), PHP_EOL;
                } else {
                    echo "Duplicate location not added.", PHP_EOL;
                }

            }

        }

    }
}