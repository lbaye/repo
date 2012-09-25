<?php

namespace Repository;

use Document\CachedPlacesData as CachedPlacesData;

class CachedPlacesDataRepo extends Base {

    public function map(array $data, CachedPlacesData $instance = null) {
        if (is_null($instance)) {
            $instance = new \Document\CachedPlacesData();
        }

        $this->setAttributes($instance, $data);

        return $instance;
    }

    public function buildId(array $location) {
        return 'lat:' . $location['lat'] . ':lng:' . $location['lng'];
    }

    private function setAttributes(CachedPlacesData &$instance, array $data) {
        $setIfExistFields = array(
            'lat' => 'lat',
            'lng' => 'lng',
            'cachedData' => 'cachedData',
            'source' => 'source'
        );

        foreach ($setIfExistFields as $externalField => $field) {
            if (isset($data[$externalField]) && !is_null($data[$externalField])) {
                $method = "set" . ucfirst($field);
                $instance->$method($data[$externalField]);
            }
        }

        $instance->setId(
            $this->buildId(
                array('lat' => $instance->getLat(),
                      'lng' => $instance->getLng())));
    }
}