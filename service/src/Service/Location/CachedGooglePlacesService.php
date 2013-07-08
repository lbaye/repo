<?php

namespace Service\Location;

use Monolog\Logger as Logger;

/**
 * Find search results from cached google places record.
 */
class CachedGooglePlacesService implements \Service\Location\IPlacesService
{

    private $mRepository;
    private $mService;
    private $mLogger;

    public function __construct(
        Logger $logger,
        \Repository\CachedPlacesDataRepo $repository,
        \Service\Location\IPlacesService $placesService)
    {
        $this->mLogger = $logger;
        $this->mRepository = $repository;
        $this->mService = $placesService;
    }

    public function search(array $location, $keywords, $radius = 2000)
    {
        $this->mLogger->debug("Searching location with - " . json_encode($location) .
                              ' and keywords ' . $keywords . ' in radius - ' . $radius);
        $this->ensureLocationIsSet($location);

        # Round lat and lng value
        $rounded_location = array(
            'lat' => round($location['lat'], 2),
            'lng' => round($location['lng'], 2)
        );

        # Search CachedPlacesData by rounded lat and lng
        $cachedData = $this->mRepository->find($this->mRepository->buildId($rounded_location));
        if ($cachedData == null) {
            $this->mLogger->debug("No places cache found");
            # If not found retrieve from google
            # Cache google places result
            $result = $this->mService->search($rounded_location, $keywords, $radius);

            if (!empty($result)) {
                $this->mRepository->insert($this->mRepository->map(array(
                    'lat' => $rounded_location['lat'],
                    'lng' => $rounded_location['lng'],
                    'source' => 'google',
                    'cachedData' => $result)));
            }

            return $result;
        } else {
            $this->mLogger->debug('Found places in cache.');
            return $this->updateDistance($location, $cachedData->getCachedData());
        }
    }

    private function updateDistance($location, $cachedData)
    {
        if (!empty($cachedData)) {
            foreach ($cachedData as &$place) {
                $place->distance = \Helper\Location::distance(
                    $location['lat'], $location['lng'],
                    $place->geometry->location->lat,
                    $place->geometry->location->lng);
            }
        }
        return $cachedData;
    }

    private function ensureLocationIsSet($location)
    {
        if (!isset($location['lat']) || !isset($location['lng'])) {
            throw new \Exception("Lat and Lng parameters are not set.");
        }
    }
}
