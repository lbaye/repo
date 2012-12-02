<?php

namespace Repository;

use Document\CacheRef as CacheRef;

class CacheRefRepo extends Base {

    public function getReferencesWhereImIn(\Document\User $user) {
        return $this->dm->createQueryBuilder('Document\CacheRef')
            ->select('_id', 'cacheFile')
            ->field('participants')->in(array($user->getId()))
            ->hydrate(false)->getQuery()->execute();
    }
}

