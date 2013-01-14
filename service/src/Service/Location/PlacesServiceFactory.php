<?php

namespace Service\Location;

use Monolog\Logger as Logger;

/**
 * Factory for providing place search related implementation
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
        $logger = new Logger('PlaceServiceFactory::' . $type);
        $logger->pushHandler(\Helper\Util::getStreamHandler(self::$mConfiguration));

        switch ($type) {
            case self::GOOGLE_PLACES:
                return new GooglePlacesService(
                    $logger,
                    self::$mConfiguration['googlePlace']['apiKey'],
                    self::$mConfiguration);

            case self::CACHED_GOOGLE_PLACES:
                return new CachedGooglePlacesService(
                    $logger, self::$mDocumentManager->getRepository('Document\CachedPlacesData'),
                    self::buildNewInstance(self::GOOGLE_PLACES)
                );

        }
    }
}
