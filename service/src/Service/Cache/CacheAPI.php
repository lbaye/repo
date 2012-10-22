<?php

namespace Service\Cache;

/**
 * Find search results from cached google places record.
 */


class CacheAPI
{

    private $mRepository;

    public function __construct(\Doctrine\ODM\MongoDB\DocumentManager $dm)
    {

        $this->mRepository = $dm->getRepository('Document\CachedData');
    }

    public function get($id) {
        return $this->mRepository->find($id);
    }


    public function put(\Document\CachedData $instance) {
        $this->mRepository->insert($instance);
        return true;
    }

    public function destroy($id) {
        $this->mRepository->delete($id);

        return true;
    }
}
