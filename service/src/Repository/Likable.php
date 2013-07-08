<?php

namespace Repository;

/**
 * Interface for declaring a DAO as likable
 */
interface Likable {
    public function like($object, $user);
    public function unlike($object, $user);
    public function hasLiked($object, $user);
    public function getLikes($object);
}
