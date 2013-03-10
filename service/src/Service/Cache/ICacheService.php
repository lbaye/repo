<?php

namespace Service\Cache;

/**
 *  Cache data for a location(lat,lng) i.e. address
 */
interface ICacheService {

    /**
     * Retrieve places filtering by +$keywords+ and +$location+
     *
     * @abstract
     * @param array $location
     * @param string $keywords
     * @param int $radius
     * @return void
     */
    public function put($cacheKey, $data, $lat, $lng, $type);
    public function get($cacheKey);
}
