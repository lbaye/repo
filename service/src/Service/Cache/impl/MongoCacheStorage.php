<?php

namespace Service\Cache\impl;

/**
 * Mongodb based caching storage implementation
 */
class MongoCacheStorage implements \Service\Cache\CacheStorage
{

    private $mRepository;

    public function __construct(\Doctrine\ODM\MongoDB\DocumentManager $dm)
    {
        $this->mRepository = $dm->getRepository('Document\CachedData');
    }

    public function get($id) {
        return $this->mRepository->find($id);
    }


    public function put($cacheKey, \Document\CachedData $cache) {
        $cache->setId( $cacheKey );
        $this->mRepository->put($cache);
        return true;
    }

    public function destroy($id) {
        $this->mRepository->delete($id);

        return true;
    }

}
