<?php

namespace Service\Search;

interface ApplicationSearchInterface {
    public function searchAll(array $params, $options = array());
    public function searchPeople(array $params, $options = array());
    public function searchPlaces(array $params, $options = array());
    public function searchSecondDegreeFriends(array $params, $options = array());
}
