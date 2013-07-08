<?php

namespace Exception;

/**
 * Thrown when an unauthorized request is made.
 *
 * @author Emran Hasan <emran@loosemonkies.com>
 */
class UnauthorizedException extends \Exception
{
    public function __construct()
    {
        parent::__construct('The authorization token is not valid for the requesting operation.', 401);
    }
}