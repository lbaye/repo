<?php

namespace Event;

use Repository\ExternalLocationRepo as ExternalLocationRepository;

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
//        $getCheckinByAuth = $facebook->getCheckinByAuth($workload->facebookId, $workload->facebookAuthToken);
        $locationsCheckin = $facebook->getFriendCheckin($workload->facebookId, $workload->facebookAuthToken);

       if (count($locationsCheckin) > 0) {

           foreach ($locationsCheckin['data'] as $checkin) {
               $authIdReindex = (int) $checkin['author_uid'];
               $checkinReindex[$authIdReindex]['coords'] = array('longitude' => $checkin['coords']['longitude'], 'latitude' => $checkin['coords']['latitude']);
               $checkinReindex[$authIdReindex]['timestamp'] = $checkin['timestamp'];

           }
       }
       $locations = $facebook->getFriendInfo($workload->facebookId, $workload->facebookAuthToken);
       $ownerFacebookId = $workload->facebookId;

        if (count($locations) > 0) {
            $i = 0;

            foreach ($locations['data'] as $location) {

                    if (!$this->externalLocationRepository->exists($location['uid'])) {
                         $uidReindex = (int) $location['uid'];
                         $locationFinal['source'] = 'fb-public';
                         $locationFinal['uid'] = $location['uid'];
                         $locationFinal['name'] = $location['name'];
                         $locationFinal['gender'] = $location['gender'];
                         $locationFinal['location'] = $location['location'];
                         $locationFinal['email'] = $location['email'];
                         $locationFinal['picSquare'] = $location['pic_square'];
                         $locationFinal['ownerFacebookId'] = $ownerFacebookId;

                         if(!empty($checkinReindex[$uidReindex]['coords'])) {
                            $locationFinal['coords'] = $checkinReindex[$uidReindex]['coords'];
                            $locationFinal['refTimestamp'] = $checkinReindex[$uidReindex]['timestamp'];
                         }
                         $savedLocation = $this->externalLocationRepository->insertFromFacebook($locationFinal);
                    } else {
                         $savedLocation = false;
                    }

                if ($savedLocation) {
                    echo "Added location with ID: ", $savedLocation->getAuthId(), PHP_EOL;
                } else {
                    echo "Duplicate location not added.", PHP_EOL;
                }

            }

        }

    }
}