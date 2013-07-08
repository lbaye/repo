<?php

namespace Exception;

/**
 * Thrown when a requested resource cannot be created to avoid duplication.
 *
 * @author Emran Hasan <emran@loosemonkies.com>
 */
class ResourceAlreadyExistsException extends \Exception
{
    public function __construct($identifier = '')
    {
        parent::__construct(sprintf('A resource with the identifier %s already exist.', $identifier), 400);
    }
}