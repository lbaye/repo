<?php

namespace Document;

/**
 * Interface for declaring a class as participative
 */
interface ParticipativeDoc {

    public function getLikesCount();
    public function getCommentsCount();
}
