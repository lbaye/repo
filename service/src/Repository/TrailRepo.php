<?php

namespace Repository;

use Doctrine\ODM\MongoDB\DocumentRepository;
use Document\Trail as TrailDocument;
use Document\MapixTrail as MapixTrailDocument;
use Document\BreadcrumbTrail as BreadcrumbTrailDocument;
use Document\User as UserDocument;
use Helper\Security as SecurityHelper;

/**
 *
 */
class TrailRepo extends Base
{

    /**
     * @param $data
     * @param $id
     * @return bool|\Document\Trail
     * @throws \Exception\ResourceNotFoundException
     */
    public function update($data, $id)
    {
        $trail = $this->find($id);
        if (false === $trail) throw new \Exception\ResourceNotFoundException();

        $trail = $this->map($data, $trail->getOwner(), $trail);
        return $this->updateObject($trail);
    }

    /**
     * @param array $data
     * @param \Document\User $owner
     * @param \Document\Trail $trail
     * @return \Document\Trail
     */
    public function map(array $data, UserDocument $owner, TrailDocument $trail = null)
    {

        if (is_null($trail)) {
            $trail =  $this->getDocumentObj();
            $trail->setCreatedDate((new \DateTime()));
        } else {
            $trail->setUpdatedDate((new \DateTime()));
        }

        $setIfExistFields = array('name', 'description');

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $trail->{"set{$field}"}($data[$field]);
            }
        }

        $trail->setOwner($owner);

        // extracting marker information
        $field = 'markers';
        if (isset($data[$field]) && !is_null($data[$field])) {
            $markerArray = $data[$field];
            foreach ($markerArray as $aMarker) {
                $lat = $aMarker['lat'];
                $lng = $aMarker['lng'];
                $venueID = $aMarker['venueID'];
                $markerNumber = $aMarker['markerNumber'];
                $aMarkerObject = new \Document\Marker();
                $aMarkerObject->setLat($lat);
                $aMarkerObject->setLng($lng);
                $aMarkerObject->setVenueID($venueID);
                $aMarkerObject->setMarkerNumber($markerNumber);
                $trail->addMarker($aMarkerObject);
            }
        }

        return $trail;
    }

    private function getDocumentObj()
    {
        if ('Document\MapixTrail' == $this->documentName) {
            $trail = new MapixTrailDocument();
            return $trail;

        } else if ('Document\BreadcrumbTrail' == $this->documentName) {
            $trail = new BreadcrumbTrailDocument();
            return $trail;

        } else {
            $trail = new TrailDocumentDocument();
            return $trail;
        }
    }

    /**
     * @param $id
     * @throws \Exception
     */
    public function delete($id)
    {
        $trail = $this->find($id);

        if (is_null($trail)) {
            throw new \Exception("Not found", 404);
        }

        $this->dm->remove($trail);
        $this->dm->flush();
    }

    /**
     * @param $data
     * @param $id
     * @return bool|\Document\Trail
     * @throws \Exception\ResourceNotFoundException
     */
    public function addMarker($data, $id)
    {
        $trail = $this->find($id);

        if (false === $trail) {
            throw new \Exception\ResourceNotFoundException();
        }

        $trail = $this->mapMarker($data, $trail->getOwner(), $trail);

        if ($trail->isValid() === false) {
            return false;
        }

        $this->dm->persist($trail);
        $this->dm->flush();

        return $trail;
    }

    /**
     * @param array $data
     * @param \Document\User $owner
     * @param \Document\Trail $trail
     * @return \Document\Trail
     */
    public function mapMarker(array $data, UserDocument $owner, TrailDocument $trail = null)
    {
        # TODO: Does not check for duplicate markers


        if (is_null($trail)) {
            $trail = new TrailDocument();
        }

        $trail->setOwner($owner);

        $setIfExistFields = array('lat', 'lng', 'venueID', 'markerNumber');
        $aMarkerObject = new \Document\Marker();
        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {

                $aMarkerObject->{"set{$field}"}($data[$field]);
            }
        }

        $trail->addMarker($aMarkerObject);
        return $trail;
    }

    /**
     * @param $data
     * @param $id
     * @return bool|\Document\Trail|object
     * @throws \Exception\ResourceNotFoundException
     */
    public function deleteMarker($data, $id)
    {
        $trail = $this->find($id);

        if (false === $trail) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (is_null($trail)) {
            $trail = new TrailDocument();
        }

        /// get marker array
        $toDeleteMarkerNumber = $data['markerNumber'];

        $markers = $trail->getMarkers();
        $trail->resetMarkers();
        foreach ($markers as $aMarkerObject) {

            if ($aMarkerObject->getMarkerNumber() != $toDeleteMarkerNumber) {
                $trail->addMarker($aMarkerObject);
            }

        }

        if ($trail->isValid() === false) {
            return false;
        }

        $this->dm->persist($trail);
        $this->dm->flush();

        return $trail;
    }

    public function addPhotoToMarker($data, $id)
    {
        $trail = $this->find($id);

        if (false === $trail) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (is_null($trail)) {
            $trail = new TrailDocument();
        }

        $markers = $trail->getMarkers();
        $markerNumberToUpdate = $data['markerNumber'];

        foreach ($markers as $aMarkerObject) {

            if ($aMarkerObject->getMarkerNumber() == $markerNumberToUpdate) {
               // we need to add photo to this marker
                // iterate over the photo
                // extract the array
                $field = 'photos';
                if (isset($data[$field]) && !is_null($data[$field])) {
                    $photoIdArray = $data[$field];
                    foreach ($photoIdArray as $aPhotoID) {
                        $aMarkerObject->addPhoto($aPhotoID);
                    } // end for each
                }
            }
        }

        if ($trail->isValid() === false) {
            return false;
        }

        $this->dm->persist($trail);
        $this->dm->flush();

        return $trail;
    }

    public function deletePhotoFromMarker($data, $id)
    {
        $trail = $this->find($id);

        if (false === $trail) {
            throw new \Exception\ResourceNotFoundException();
        }

        if (is_null($trail)) {
            $trail = new TrailDocument();
        }

        /// get marker array
        $toDeleteMarkerNumber = $data['markerNumber'];

        $markers = $trail->getMarkers();

        foreach ($markers as $aMarkerObject) {

            if ($aMarkerObject->getMarkerNumber() == $toDeleteMarkerNumber) {
                // now delete the photo
                $field = 'photoID';
                if (isset($data[$field]) && !is_null($data[$field])) {
                    $aMarkerObject->deletePhoto($data[$field]);
                }
            }
        }

        if ($trail->isValid() === false) {
            return false;
        }

        $this->dm->persist($trail);
        $this->dm->flush();

        return $trail;
    }


}
