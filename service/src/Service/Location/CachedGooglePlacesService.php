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

        # Round lat and lng value
        $location['lat'] = round($location['lat'], 2);
        $location['lng'] = round($location['lng'], 2);

        # Search CachedPlacesData by rounded lat and lng
        $cachedData = $this->mRepository->find($this->mRepository->buildId($location));
        if ($cachedData == null) {
            # If not found retrieve from google
            # Cache google places result
            $result = $this->mService->search($location, $keywords, $radius);
            $this->mRepository->insert($this->mRepository->map(array(
                'lat' => $location['lat'],
                'lng' => $location['lng'],
                'source' => 'google',
                'cachedData' => $result)));
            return $result;
        } else {
            return $cachedData->getCachedData();
        }
    }

    private function buildCache($result, $location) {

    }

    private function ensureLocationIsSet($location) {
        if (!isset($location['lat']) || !isset($location['lng'])) {
            throw new \Exception("Lat and Lng parameters are not set.");
        }
    }
}
