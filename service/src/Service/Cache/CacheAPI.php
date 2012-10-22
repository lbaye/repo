<?php

namespace Service\Cache;

/**
 * Find search results from cached google places record.
 */


class CacheAPI implements \Service\Cache\ICacheService
{

    private $mRepository;

    public function __construct(\Doctrine\ODM\MongoDB\DocumentManager $dm)
    {

        $this->mRepository = $dm->getRepository('Document\CachedData');
    }

    public function get($id) {
        return $this->mRepository->find($id);
    }


    public function put($id, $data, $lat, $lng, $type) {

        $instance = new \Document\CachedData;
        $instance->setId($id);
        $instance->setData($data);
        $instance->setType($type);
        $instance->setLat($lat);
        $instance->setLng($lng);
        $this->mRepository->put($instance);
        return true;
    }

    public function destroy($id) {
        $this->mRepository->delete($id);

        return true;
    }
}
