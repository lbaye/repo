<?php

namespace Exception;

/**
 * Thrown when a requested resource does not exist.
 *
 * @author Emran Hasan <emran@loosemonkies.com>
 */
class ResourceNotFoundException extends \Exception
{
    public function __construct()
    {
        parent::__construct('The requested resource does not exist.', 404);
    }
}