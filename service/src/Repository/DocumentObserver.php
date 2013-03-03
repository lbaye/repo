<?php

namespace Repository;

/**
 * Interface for document observer
 */
interface DocumentObserver {
    public function beforeValidation(&$object);
    public function beforeCreate(&$object);
    public function afterCreate(&$object);

    public function beforeUpdate(&$object);
    public function afterUpdate(&$object);

    public function beforeDestroy(&$object);
    public function afterDestroy(&$object);

    public function announcement($type, array $object);

    public function getName();
}
