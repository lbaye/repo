<?php

namespace Repository;

use Document\CacheRef as CacheRef;

/**
 * Data access functionality for cache references model
 */
class CacheRefRepo extends Base {

    public function getReferencesWhereImCached(\Document\User &$user) {
        return $this->dm->createQueryBuilder('Document\CacheRef')
            ->select('_id', 'cacheFile', 'owner')
            ->field('participants')->in(array($user->getId()))
            ->hydrate(false)->getQuery()->execute();
    }

    public function cleanupExistingReferences(\Document\User &$user) {
        $refs = $this->dm->createQueryBuilder('Document\CacheRef')
            ->select('_id')->field('owner')->equals($user->getId())->hydrate(false)
            ->getQuery()->execute();

        foreach ($refs as $ref) $this->delete($ref['_id']);
    }
}

