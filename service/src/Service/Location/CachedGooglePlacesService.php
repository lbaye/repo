<?php

namespace Service\Location;

/**
 * Find search results from cached google places record.
 */
class CachedGooglePlacesService implements \Service\Location\IPlacesService {

    private $mRepository;
    private $mService;

    public function __construct(
        \Repository\CachedPlacesDataRepo $repository,
        \Service\Location\IPlacesService $placesService) {

        $this->mRepository = $repository;
        $this->mService = $placesService;
    }

    public function search(array $location, $keywords, $radius = 2000) {
        $this->ensureLocationIsSet($location);

        $location['lat'] = round($location['lat'], 2);
        $location['lng'] = round($location['lng'], 2);

        $cachedData = $this->mRepository->find($this->mRepository->buildId($location));
        if ($cachedData == null) {
            $result = $this->mService->search($location, $keywords, $radius);

            $this->mRepository->insert($this->mRepository->map(array(
                'lat' => $rounded_location['lat'],
                'lng' => $rounded_location['lng'],
                'source' => 'google',
                'cachedData' => $result)));
            return $result;
        } else {
            return $this->updateDistance($location, $cachedData->getCachedData());
        }
    }

    private function updateDistance($location, $cachedData) {
        foreach ($cachedData as &$place) {
            $place->distance = \Helper\Location::distance(
                $location['lat'], $location['lng'],
                $place->geometry->location->lat,
                $place->geometry->location->lng);
        }
        return $cachedData;
    }

    private function ensureLocationIsSet($location) {
        if (!isset($location['lat']) || !isset($location['lng'])) {
            throw new \Exception("Lat and Lng parameters are not set.");
        }
    }
}
