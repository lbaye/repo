<?php

namespace Service\Location;

/**
 * Provide factory methods for managing places instance.
 */
class PlacesServiceFactory {

    const GOOGLE_PLACES = 'google';
    const CACHED_GOOGLE_PLACES = 'cached_google';

    private static $mInstances = array();
    private static $mConfiguration;
    private static $mDocumentManager;

    public static function getInstance(&$documentManager, $configuration, $type = self::GOOGLE_PLACES) {
        self::$mDocumentManager = $documentManager;
        self::$mConfiguration = $configuration;

        if (isset(self::$mInstances[$type])) {
            return self::$mInstances[$type];
        } else {
            return self::$mInstances[$type] = self::buildNewInstance($type);
        }
    }

    private static function buildNewInstance($type) {
        switch ($type) {
            case self::GOOGLE_PLACES:
                return new GooglePlacesService(self::$mConfiguration['googlePlace']['apiKey']);

            case self::CACHED_GOOGLE_PLACES:
                return new CachedGooglePlacesService(
                    self::$mDocumentManager->getRepository('Document\CachedPlacesData'),
                    self::buildNewInstance(self::GOOGLE_PLACES)
                );

        }
    }
}
