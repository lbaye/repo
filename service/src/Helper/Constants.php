<?php
namespace Helper;

/**
 * Helper for keeping commonly used constants
 */
class Constants {
    const CT_SEARCH = 'search';
    const TYPE_PLAN = 'plan';

    const DISTANCE_UPPER_LIMIT = 55000000;
    /* Km to radius (km / 111.2) */
    const DEFAULT_RADIUS = .017985612;
    const PEOPLE_LIMIT = 40;
    const PEOPLE_LIMIT_KEYWORD = 1000;
    const GLOBAL_MAX_ALLOWED_OLDER_CHECKINS = '336 hours ago';

    const APN_REFRESH_SEARCH_CACHE = 'refresh_search_cache';
    const APN_CREATE_SEARCH_CACHE = 'create_search_cache';
    const APN_PROXIMITY_ALERT = 'proximity_alert';
    const APN_UPDATE_LAST_SEEN_AT = 'update_last_seen_address';
}
