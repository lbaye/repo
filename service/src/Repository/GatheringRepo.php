<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Meetup as MeetupDocument;
use Document\Event as EventDocument;
use Document\Plan as PlanDocument;
use Document\User as UserDocument;
use Repository\UserRepo as UserRepository;
use Helper\Security as SecurityHelper;
use Helper\Image as ImageHelper;
use Helper\Constants as Constants;

class GatheringRepo extends Base implements Likable
{

    public function getByUser(UserDocument $user)
    {
        $gatherings = $this->findBy(array('owner' => $user->getId()), array('createDate' => 'DESC'));
        return $this->_toArrayAll($gatherings);
    }

    public function getAll($limit = 20, $offset = 0)
    {
        return $this->findBy(array(), array('createDate' => 'DESC'), $limit, $offset);
    }

    public function getAllActiveEvent($limit = 20, $offset = 0)
    {
        $hour = date('H');
        $minute = date('i');
        $_dateTime = new \DateTime($hour . 'hours ' . $minute . ' minutes ago');

        $events = $this->createQueryBuilder()
            ->field('time')->gte($_dateTime)
            ->sort(array('createDate' => 'DESC'))
            ->limit($limit)
            ->getQuery()
            ->execute();

        return $events;
    }

    public function insert($gatheringObj)
    {
        $valid  = $gatheringObj->isValid();

        if ($valid !== true) {
            throw new \InvalidArgumentException('Invalid data', 406);
        }

        $this->dm->persist($gatheringObj);
        $this->dm->flush($gatheringObj);

        return $gatheringObj;
    }

    public function update($data, $gathering)
    {
        if (   !$gathering instanceof \Document\Event
            && !$gathering instanceof \Document\Meetup
            && !$gathering instanceof \Document\Plan) {
            throw new \Exception\ResourceNotFoundException();
        }

        $gathering = $this->map($data, $gathering->getOwner(), $gathering);
        return $this->updateObject($gathering);
    }

    public function addGuests($newGuests, $gathering)
    {
        if (   !$gathering instanceof \Document\Event
            && !$gathering instanceof \Document\Meetup
            && !$gathering instanceof \Document\Plan) {
            throw new \Exception\ResourceNotFoundException();
        }

        $guests = $gathering->getGuests();

        $gathering->setGuests(array_unique(array_merge($guests, $newGuests)));

        $this->dm->persist($gathering);
        $this->dm->flush();

        return $gathering;
    }

    public function addCircles($newCircles, $gathering)
    {
        if (   !$gathering instanceof \Document\Event
            && !$gathering instanceof \Document\Meetup
            && !$gathering instanceof \Document\Plan) {
            throw new \Exception\ResourceNotFoundException();
        }

        $circles = $gathering->getInvitedCircles();
        foreach($newCircles as $circle) array_push($circles, $circle);

        $gathering->setInvitedCircles($circles);

        $this->dm->persist($gathering);
        $this->dm->flush();

        return $gathering;
    }

    public function delete($id)
    {
        $gatheringObj = $this->find($id);

        if (is_null($gatheringObj)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($gatheringObj);
        $this->dm->flush();
    }

    public function map(array $data, UserDocument $owner, \Document\Gathering $gathering = null, $type = null)
    {
        if(is_null($gathering)){
            $gathering = $this->getDocumentObj();

            $gathering->setCreateDate(new \DateTime());
        } else {
            $gathering->setUpdateDate(new \DateTime());
        }

        $setIfExistFields = array('title', 'description', 'duration','message','eventShortSummary', 'time', 'guestsCanInvite');

        foreach($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $gathering->{"set{$field}"}($data[$field]);
            }
        }

        if($type == Constants::TYPE_PLAN && isset($data['description'])){
            $gathering->setEventShortSummary($data['description']);
        }

        if(isset($data['guests']) && is_array($data['guests'])){
            $users = $this->trimInvalidUsers($data['guests']);
            $users[] = $owner->getId();
            $gathering->setGuests($users);
        }else{
            $guests[] = $owner->getId();
            $gathering->setGuests($guests);
        }

        if(isset($data['invitedCircles']) && is_array($data['invitedCircles'])){
            $gathering->setInvitedCircles($data['invitedCircles']);
        }

        if(isset($data['permission'])){
            $gathering->share($data['permission'], @$data['permittedUsers'], @$data['permittedCircles']);
        }

        if(isset($data['lat']) && isset($data['lng'])){
           $gathering->setLocation(new \Document\Location($data));
        }

        $gathering->setOwner($owner);

        return $gathering;
    }

    private function getDocumentObj()
    {
        if ('Document\Meetup' == $this->documentName) {
            $gathering = new MeetupDocument();
            return $gathering;

        } else if ('Document\Plan' == $this->documentName) {
            $gathering = new PlanDocument();
            return $gathering;

        } else {
            $gathering = new EventDocument();
            return $gathering;
        }
    }

    protected function trimInvalidUsers($data)
    {
        $userRepo = $this->dm->getRepository('Document\User');
        $users = array();

        foreach ($data as $guestId) {
            $user = $userRepo->find($guestId);
            if ($user) array_push($users, $user->getId());
        }
        return $users;
    }

    protected function getValidUsers(array $userIds)
    {

    }

    private function getDocType()
    {
        return strtolower(substr($this->documentName, 9));
    }

    protected function _toArrayAll($results)
    {
        $gatheringItems = array();
        foreach ($results as $place) {
            $gatheringItems[] = $place->toArray();
        }

        return $gatheringItems;
    }

     public function updateWhoWillAttend($data, $gathering)
    {
        if (   !$gathering instanceof \Document\Event
            && !$gathering instanceof \Document\Meetup
            && !$gathering instanceof \Document\Plan) {
            throw new \Exception\ResourceNotFoundException();
        }

        $gathering = $this->map($data, $gathering->getOwner(), $gathering);

        if ($gathering->isValid() === false) {
            return false;
        }

        $this->dm->persist($gathering);
        $this->dm->flush();

        return $gathering;
    }

    public function saveEventImage($id , $eventImage)
    {
        $user = $this->find($id);

        if (false === $user) {
            throw new \Exception\ResourceNotFoundException();
        }

        $user->setUpdateDate(new \DateTime());
        $timeStamp = $user->getUpdateDate()->getTimestamp();
        $filePath = "/images/event-photo/" . $user->getId();
        $eventImageUrl = filter_var($eventImage, FILTER_VALIDATE_URL);

        if ($eventImageUrl !== false) {
            $user->setEventImage($eventImageUrl);
        } else {

            ImageHelper::saveImageFromBase64($eventImage, ROOTDIR .$filePath);
            $user->setEventImage($filePath. "?". $timeStamp);
        }

        $this->dm->persist($user);
        $this->dm->flush();

        return $user;
    }

    public function getInvitedMeetups($userId)
    {
        $_dateTime = new \DateTime('now-2 hours', new \DateTimeZone('UTC'));

        $meetUpLIst = $this->createQueryBuilder()
            ->field('rsvp.no')->notIn($userId)
            ->field('time')->gte($_dateTime)
            ->sort(array('createDate' => 'DESC'))
            ->getQuery()
            ->execute();

        return $meetUpLIst;
    }
    
    public function planToArray($data,$key)
    {

        $lat = $data['location']['lat'];
        $lng = $data['location']['lng'];
        unset($data['rsvp'], $data['guestsCanInvite'], $data['distance'], $data['description'], $data['ownerDetail'],
        $data['event_type'], $data['my_response'],
        $data['is_invited'], $data['guests'], $data['owner']);

        $data['image'] = "http://maps.googleapis.com/maps/api/streetview?size=320x165&location=" . $lat . "," . $lng . "&fov=90&heading=235&pitch=10&sensor=false&key={$key}";
        $data['description'] = $data['eventShortSummary'];

        unset($data['eventShortSummary'], $data['eventImage']);

        return $data;
    }
    
    public function like($gathering, $user) {
        return $this->dm->createQueryBuilder('Document\Gathering')
                ->update()
                ->field('likes')->addToSet($user->getId())
                ->field('id')->equals($gathering->getId())
                ->getQuery()
                ->execute();
    }

    public function unlike($gathering, $user) {
        return $this->dm->createQueryBuilder('Document\Gathering')
                ->update()
                ->field('likes')->pull($user->getId())
                ->field('id')->equals($gathering->getId())
                ->getQuery()
                ->execute();
    }

    public function hasLiked($gathering, $user) {
        if ($gathering->getLikesCount() > 0)
            return in_array($user->getId(), $gathering->getLikes());

        return false;
    }
    
}