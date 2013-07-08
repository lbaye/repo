<?php

namespace Service\Cache;

/**
 *  Cache data for a location(lat,lng) i.e. address
 */
interface CacheStorage {

    /**
     * Retrieve places filtering by +$keywords+ and +$location+
     *
     * @abstract
     * @param array $location
     * @param string $keywords
     * @param int $radius
     * @return void
     */
    public function put($cacheKey, \Document\CachedData $cache);

    /**
     * @abstract
     *
     * Return instance of cache data object if found with the specified cache key
     *
     * @param  $cacheKey
     * @return \Document\CachedData an instance of cached data
     */
    public function get($cacheKey);
}
