<?php
namespace Helper;

class Constants {
    const CT_SEARCH = 'search';
    const TYPE_PLAN = 'plan';

    const DISTANCE_UPPER_LIMIT = 55000000;
    /* Km to radius (km / 111.2) */
    const DEFAULT_RADIUS = .017985612;
    const PEOPLE_LIMIT = 2000;

    const APN_REFRESH_SEARCH_CACHE = 'refresh_search_cache';
    const APN_PROXIMITY_ALERT = 'proximity_alert';
    const APN_UPDATE_LAST_SEEN_AT = 'update_last_seen_address';
}
