<?php

namespace Repository;

use Document\ExternalUser as ExtUser;

class ExternalUserRepo extends Base {

    public function exists($fbId) {
        $externalLocation = $this->findOneBy(
            array('refId' => $fbId,
                  'refType' => \Document\ExternalUser::SOURCE_FB));

        return !is_null($externalLocation);
    }

    public function map(array $data, ExtUser $ext_user = null) {
        if (empty($ext_user))
            $ext_user = new ExtUser();

        foreach ($data as $key => $value)
            $ext_user->{ 'set' . ucfirst($key) }($value);

        return $ext_user;
    }
}