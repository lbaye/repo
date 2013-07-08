<?php
namespace Document;

/**
 * Observer abstract implement for domain model
 */
class AbstractObserver implements \Repository\DocumentObserver {
    public function getName() {
        // TODO: Implement getName() method.
    }

    public function announcement($type, array $object) {
        // TODO: Implement announcement() method.
    }

    public function afterDestroy(&$object) {
        // TODO: Implement afterDestroy() method.
    }

    public function beforeDestroy(&$object) {
        // TODO: Implement beforeDestroy() method.
    }

    public function afterUpdate(&$object) {
        // TODO: Implement afterUpdate() method.
    }

    public function beforeUpdate(&$object) {
        // TODO: Implement beforeUpdate() method.
    }

    public function afterCreate(&$object) {
        // TODO: Implement afterCreate() method.
    }

    public function beforeCreate(&$object) {
        // TODO: Implement beforeCreate() method.
    }

    public function beforeValidation(&$object) {
        // TODO: Implement beforeValidation() method.
    }

}
