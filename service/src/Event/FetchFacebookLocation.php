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

        foreach ($locations['data'] as $location) {
            $location['source'] = 'fb';
            $savedLocation = $this->externalLocationRepository->insertFromFacebook($location);
            echo "Added location with ID: ", $savedLocation->getRefId(), PHP_EOL;
        }
    }

}