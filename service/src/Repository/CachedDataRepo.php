<?php
/**
 * Created by JetBrains PhpStorm.
 * User: azhar
 * Date: 10/20/12
 * Time: 7:04 PM
 * To change this template use File | Settings | File Templates.
 */

namespace Repository;

use Document\CachedData as CachedData;

class CachedDataRepo extends Base {

    public function buildId($id , $type) {
        return $type . ':' . $id;
    }

    public function put($id, $data, $type, CachedData $instance = null) {
        if (is_null($instance)) {
            $instance = new \Document\CachedData();
        }

        $instance->setId($this->buildId($id, $type));
        $instance->setData($data);
        $instance->setType($type);

        $this->dm->persist($instance);
        $this->dm->flush();

        return $instance;
    }

    public function get($id){
        $cached_data = $this->findOneBy(array('id' => $id));
        return is_null($cached_data) ? false : $cached_data;
    }

}

