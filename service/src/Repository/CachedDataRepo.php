<?php

namespace Repository;

use Document\CachedData as CachedData;

/**
 * Data access functionality for cached data model
 */
class CachedDataRepo extends Base {

    public function buildId($id , $type) {
        return $type . ':' . $id;
    }

    public function put(CachedData $instance) {
        $this->dm->persist($instance);
        $this->dm->flush();

        return true;
    }

    public function get($id){
        $cached_data = $this->find($id);
        return is_null($cached_data) ? false : $cached_data;
    }

}

