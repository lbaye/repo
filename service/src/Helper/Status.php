<?php
namespace Helper;

class Status {
    
    // HTTP Status codes
    const OK                  = 200;
    const CREATED             = 201;
    const ACCEPTED            = 202;
    const NO_CONTENT          = 204;
    const MOVED_PERMANENTLY   = 301;
    const SEE_OTHER           = 303;
    const NOT_MODIFIED        = 304;
    const PERMANENT_REDIRECT  = 308;
    const BAD_REQUEST         = 400;
    const UNAUTHORIZED        = 401;
    const FORBIDDEN           = 403;
    const NOT_FOUND           = 404;
    const METHOD_NOT_ALLOWED  = 405;
    const NOT_ACCEPTABLE      = 406;
    const REQUEST_TIMEOUT     = 408;
    const INTERNAL_SERVER_ERR = 500;
    const NOT_IMPLEMENTED     = 501;
    const BAD_GATEWAY         = 502;
    const SERVICE_UNAVAILABLE = 503;

}
