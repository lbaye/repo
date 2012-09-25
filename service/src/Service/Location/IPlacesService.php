<?php
namespace Service\Location;

/**
 * Retrieve places from the specific location.
 */
interface IPlacesService {

    /**
     * Retrieve places filtering by +$keywords+ and +$location+
     *
     * @abstract
     * @param array $location
     * @param string $keywords
     * @param int $radius
     * @return void
     */
    function search(array $location, $keywords, $radius = 2000);
}
