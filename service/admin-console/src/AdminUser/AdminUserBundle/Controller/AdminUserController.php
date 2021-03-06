<?php

namespace AdminUser\AdminUserBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\RedirectResponse,
Doctrine\ODM\MongoDB\DocumentManager;
use AdminUser\AdminUserBundle\Form\LoginType;
use Repository\UserRepo as UserRepository;
use Pagerfanta\Adapter\DoctrineODMMongoDBAdapter;
use Pagerfanta\Pagerfanta;
use Document\User as UserDocument;
use Document\Place as PlaceDocument;
use Document\Event as EventDocument;

// these import the "@Route" and "@Template" annotations
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Template;
use Helper\Security as SecurityHelper;

class AdminUserController extends Controller
{

    const SALT = 'socialmaps';

    protected $file;
    protected $document;

    /**
     * @Route("/", name="_welcome")
     * @Template()
     */
    public function indexAction()
    {
        return $this->redirect('login');
    }

    /**
     * @Route("/login", name="adminuser_login")
     * @Template()
     */
    public function loginAction()
    {
        $form = $this->get('form.factory')->create(new LoginType());

        $request = $this->get('request');
        if ($this->get('session')->get('user')) {
            return $this->redirect('userlist/1');
        }

        if ('POST' == $request->getMethod()) {
            $form->bindRequest($request);
            $postData = $form->getData();
            if ($form->isValid()) {

                if (!empty($postData['email'])) {
                    $postData['email'] = strtolower($postData['email']);
                }
                $dm = $this->get('doctrine.odm.mongodb.document_manager');

                $user = $dm->getRepository('AdminUserBundle:User')->findOneBy(array('email' => $postData['email'], 'password' => sha1($postData['password'] . self::SALT), 'userType' => 'admin'));

                if (!is_null($user)) {
                    $this->get('session')->set('user', $user);

                    $this->get('session')->set('user', $user);

                    $this->get('session')->setFlash('notice', 'Success!');
                    return $this->redirect('userlist/1');

                } else {
                    $this->get('session')->set('user', $user);
                    $this->get('session')->setFlash('notice', 'Email and password does not match!');
                }

            }
        }

//        return array('form' => $form->createView());
        return $this->render('AdminUserBundle:AdminUser:login.html.twig', array('form' => $form->createView()));
    }

    /**
     * @Route("/userlist/1", defaults={"page" = 1}, name="adminuser_userlist")
     * @Route("/userlist/{page}", name="adminuser_userlist_paginated")
     * @param $page
     * @Template()
     */
    public function userListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            $qb = $dm->createQueryBuilder('AdminUserBundle:User');
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:userlist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * @Route("/logout", name="logout")
     * @Template()
     */
    public function logoutAction()
    {
        $request = $this->get('request');

        $this->get('session')->set('user', null);
        $this->get('session')->setFlash('success', '<i class="icon-ok"></i>&nbsp; You have successfully been logged out.');

        return $this->redirect('login');
    }

    /**
     * @Route("/userupdate", name="admin_user_updatepage")
     * @Template()
     */
    public function userUpdateAction($id)
    {
        $request = $this->get('request');
        $dm = $this->get('doctrine.odm.mongodb.document_manager');
        $entity = $dm->getRepository('AdminUserBundle:User')->findOneBy(array('_id' => $id));
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\UpdateUserType(), $entity);

        if ($request->getMethod() === 'POST') {
            $form->bindRequest($request);
            $postData = $form->getData();
            if ($form->isValid()) {
                $dm->persist($entity);
                $dm->flush();

                return $this->redirect('../userlist/1');
            }

//        $dm->refresh($user); // Add this line
        }

        return $this->render('AdminUserBundle:AdminUser:updateuser.html.twig', array(
            'form' => $form->createView(),
            'entity' => $entity));
    }

    /**
     * @Route("/searchresult/1", defaults={"page" = 1}, name="adminuser_search_result")
     * @Route("/searchresult/{page}", name="adminuser_search_result_paginated")
     * @param $page
     * @Template()
     */
    public function searchResultAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:User');
            $qb->addOr($qb->expr()->field('firstName')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('lastName')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('email')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:searchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    /**
     * @Route("/useradd", name="admin_user_addpage")
     * @Template()
     */
    public function addUserAction()
    {
        if ($this->get('session')->get('user')) {
            $this->document = new \AdminUser\AdminUserBundle\Document\User();
            $request = $this->get('request');
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\UpdateUserType());

            if ($request->getMethod() === 'POST') {
                $form->bindRequest($request);
                $postData = $form->getData();
                $entity = $dm->getRepository('AdminUserBundle:User')->findOneBy(array('email' => $postData['email']));
                if ($form->isValid() && empty($entity)) {

                    $dm->persist($this->document);
                    $dm->flush();

                    $this->get('session')->setFlash('notice', 'User added successfully!');
                    return $this->redirect('../userlist/1');
                } else {
                    $this->get('session')->setFlash('notice', 'Already registered With this email!');
                }

            }

            return $this->render('AdminUserBundle:AdminUser:adduser.html.twig', array(
                'form' => $form->createView()));
        } else {
            $this->get('session')->setFlash('notice', 'Only authorize user can add new user!');
            return $this->redirect('login');
        }
    }

    public function map(array $data, UserDocument $user = null)
    {
        if (is_null($user)) {
            $user = new AdminUser\AdminUserBundle\Document();
        }

        $setIfExistFields = array(
            'id',
            'firstName',
            'lastName',
            'gender',
            'username',
            'email',
            'authToken',
            'enabled',
            'salt',
            'password',
            'oldPassword',
            'settings',
            'confirmationToken',
            'forgetPasswordToken',
            'facebookId',
            'facebookAuthToken',
            'avatar',
            'source',
            'dateOfBirth',
            'bio',
            'age',
            'address',
            'interests',
            'workStatus',
            'circles',
            'relationshipStatus',
            'enabled',
            'regMedia',
            'lastLogin',
            'coverPhoto',
            'status',
            'company',
            'loginCount',
            'createDate',
            'updateDate'
        );

        foreach ($setIfExistFields as $field) {
            if (isset($data[$field]) && !is_null($data[$field])) {
                $user->{"set{$field}"}($data[$field]);
            }
        }


        return $user;
    }

    public function emailUserAction($id)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\EmailType());
        $dm = $this->get('doctrine.odm.mongodb.document_manager');
        $entity = $dm->getRepository('AdminUserBundle:User')->findOneBy(array('_id' => $id));
        if ($request->getMethod() === 'POST') {
            $form->bindRequest($request);
            $postData = $form->getData();
            if (!empty($postData['subject'])) {
                $subject = $postData['subject'];
            } else {
                $subject = $this->container->getParameter('sender_from');
            }
            if (!empty($postData['message'])) {
                $messageData = $postData['message'];
            }
            $transport = \Swift_SmtpTransport::newInstance('smtp.googlemail.com', 465, "ssl")
                ->setUsername('islam.rafiqul@genweb2.com')
                ->setPassword('*rafiq123');
            $mailer = \Swift_Mailer::newInstance($transport);
            $message = \Swift_Message::newInstance($subject)
                ->setSubject($subject)
                ->setFrom($this->container->getParameter('sender_email'))
                ->setTo($entity->getEmail())
                ->setBody($this->renderView('AdminUserBundle:AdminUser:user.email.txt.twig',
                array('entity' => $entity, 'postData' => $messageData)));
            $sent = $mailer->send($message);
            if ($sent) {
                $this->get('session')->setFlash('notice', 'Message sent successfully!');
            }
        }
        return $this->render('AdminUserBundle:AdminUser:email.html.twig', array('form' => $form->createView()));
    }

    /**
     * @Route("/placelist/1", defaults={"page" = 1}, name="manage_place")
     * @Route("/placelist/{page}", name="manage_place")
     * @param $page
     * @Template()
     */
    public function placeListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            $qb = $dm->createQueryBuilder('AdminUserBundle:Place');

            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();

            return $this->render('AdminUserBundle:AdminUser:placelist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * @Route("/addplace", name="addPlace")
     * @Template()
     */
    public function addPlaceAction()
    {
        if ($this->get('session')->get('user')) {
            $this->document = new \AdminUser\AdminUserBundle\Document\Place();
            $request = $this->get('request');
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\AddPlaceType());

            if ($request->getMethod() === 'POST') {
                $form->bindRequest($request);
                $postData = $form->getData();
                if ($form->isValid()) {

                    if (empty($postData['title']) || empty($postData['icon']) || empty($postData['photo']) || empty($postData['lat']) || empty($postData['lng']) || empty($postData['address'])) {
                        $this->get('session')->setFlash('notice', 'Required field can not be empty!');
                        return $this->redirect('customplacelist/1');
                    }
                    $postData['createDate'] = date('Y-m-d h:i:s a', time());
                    $postData['owner'] = $this->getUser();
                    $newLocation['lat'] = floatval($postData['lat']);
                    $newLocation['lng'] = floatval($postData['lng']);
                    $newLocation['address'] = $postData['address'];
                    $postData['location'] = $newLocation;
                    $user = $dm->getRepository('AdminUserBundle:User')->findOneBy(array('_id' => $this->get('session')->get('user')->getId()));
                    $this->document->map($postData);

                    $this->document->setOwner($user);
                    $dm->persist($this->document);
                    $dm->flush();

                    if (!empty($postData['photo']) && !empty($postData['icon'])) {
                        $this->savePlacePhoto($this->document->getId(), $postData['photo'], $postData['createDate'], $postData['icon']);
                    }

                    $this->get('session')->setFlash('notice', 'Place added successfully!');
                    return $this->redirect('customplacelist/1');
                }

            }

            return $this->render('AdminUserBundle:AdminUser:addplace.html.twig', array(
                'form' => $form->createView()));
        } else {
            $this->get('session')->setFlash('notice', 'Only authorize user can add new place!');
            return $this->redirect('login');
        }
    }

    /**
     * @Route("/placelist/{id}", name="manage_place_edit")
     * @param $id
     * @Template()
     */
    public function editPlaceAction($id)
    {
        if ($this->get('session')->get('user')) {
            $this->document = new \AdminUser\AdminUserBundle\Document\Place();
            $request = $this->get('request');
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $entity = $dm->getRepository('AdminUserBundle:Place')->findOneBy(array('_id' => $id));
            if (!empty($entity)) {
                $location = $entity->getLocation();
                if (!empty($location['lat']))
                    $entity->setLat($location['lat']);
                if (!empty($location['lng']))
                    $entity->setLng($location['lng']);
                if (!empty($location['address']))
                    $entity->setAddress($location['address']);
            }
            $prevPhoto = $entity->getPhoto();
            $prevIcon = $entity->getIcon();

            $form = $this->get('form.factory')
                ->create(new \AdminUser\AdminUserBundle\Form\UpdatePlaceType(), $entity);

            if ($request->getMethod() === 'POST') {
                $form->bindRequest($request);
                $postData = $form->getData();

                if ($form->isValid()) {
                    $title = $postData->getTitle();
                    $lat = $postData->getLat();
                    $lng = $postData->getLng();
                    $address = $postData->getAddress();

                    if (empty($title) || empty($lat) || empty($lng) || empty($address)) {
                        $this->get('session')->setFlash('notice', 'Required field can not be empty!');
                        return $this->redirect('customplacelist/1');
                    }

                    $newLocation['lat'] = floatval($postData->getLat());
                    $newLocation['lng'] = floatval($postData->getLng());
                    $newLocation['address'] = $postData->getAddress();
                    $postData->setLocation($newLocation);
                    $isUploadedPhoto = 1;
                    $isUploadedIcon = 1;
                    if (is_null($postData->getPhoto())) {
                        $postData->setPhoto($prevPhoto);
                        $isUploadedPhoto = null;
                    }

                    if (is_null($postData->getIcon())) {
                        $postData->setIcon($prevIcon);
                        $isUploadedIcon = null;
                    }

                    $dm->persist($postData);
                    $dm->flush();

                    if ($isUploadedPhoto || $isUploadedIcon) {

                        if ($isUploadedPhoto) {
                            $placePhoto = $postData->getPhoto();
                        } else {
                            $placePhoto = null;
                        }

                        if ($isUploadedIcon) {
                            $placeIcon = $postData->getIcon();
                        } else {
                            $placeIcon = null;
                        }
                        $this->updatePlacePhoto($id, $placePhoto, date('Y-m-d h:i:s a', time()), $placeIcon);

                    }

                    $this->get('session')->setFlash('notice', 'Place updated successfully!');
                    return $this->redirect('../customplacelist/1');
                }

            }


            return $this->render('AdminUserBundle:AdminUser:updateplace.html.twig', array(
                'form' => $form->createView(), 'entity' => $entity));
        } else {
            $this->get('session')->setFlash('notice', 'Only authorize user can add new place!');
            return $this->redirect('login');
        }
    }


    public function savePlacePhoto($id, $placePhoto, $createDate, $placeIcon = null)
    {
        $dm = $this->get('doctrine.odm.mongodb.document_manager');
        $place = $dm->getRepository('AdminUserBundle:Place')->findOneBy(array('_id' => $id));


        if (false === $place) {
            throw new \Exception\ResourceNotFoundException();
        }

//        $place->setUpdateDate(new \DateTime());

        $timeStamp = strtotime($createDate);
        $valid_mime_types = array(
            "image/gif",
            "image/png",
            "image/jpeg",
            "image/pjpeg",
        );

        $dirPath = "/images/place-photo/";
        $iconDirPath = "/images/place-icon/";
        $twig = $this->container->get('twig');
        $globals = $twig->getGlobals();

        $rootDir = $globals['image_real_path'];
        $destination = $rootDir . $dirPath;
        $iconDestination = $rootDir . $iconDirPath;

        $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $place->setPhoto($photoUrl);
        } else {
            if (!file_exists($rootDir . $dirPath)) {
                mkdir($destination, 0777, true);
            }

            if (in_array($_FILES['addplace']['type']['photo'], $valid_mime_types)) {
                $ext = explode('.', $_FILES['addplace']['name']['photo']);
                $ext = end($ext);
                $filePath = $destination . $place->getId() . "." . $ext;
//                move_uploaded_file($_FILES['addplace']['tmp_name']['photo'], $filePath);
                $this->imageResize(320, 130, $_FILES['addplace']['tmp_name']['photo'], $filePath);
            }

            $place->setPhoto($dirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
        }
        if (!is_null($placeIcon)) {
            $iconUrl = filter_var($placeIcon, FILTER_VALIDATE_URL);

            if ($iconUrl !== false) {
                $place->setIcon($iconUrl);
            } else {
                if (!file_exists($rootDir . $iconDirPath)) {
                    mkdir($iconDestination, 0777, true);
                }

                if (in_array($_FILES['addplace']['type']['icon'], $valid_mime_types)) {
                    $ext = explode('.', $_FILES['addplace']['name']['icon']);
                    $ext = end($ext);
                    $filePath = $iconDestination . $place->getId() . "." . $ext;
//                    move_uploaded_file($_FILES['addplace']['tmp_name']['icon'], $filePath);
                    $this->imageResize(71, 71, $_FILES['addplace']['tmp_name']['icon'], $filePath);
                }

                $place->setIcon($iconDirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
            }
        }

        $dm->persist($place);
        $dm->flush();

        return $place;
    }

    public function updatePlacePhoto($id, $placePhoto, $createDate, $placeIcon = null)
    {
        $dm = $this->get('doctrine.odm.mongodb.document_manager');
        $place = $dm->getRepository('AdminUserBundle:Place')->findOneBy(array('_id' => $id));


        if (false === $place) {
            throw new \Exception\ResourceNotFoundException();
        }

//        $place->setUpdateDate(new \DateTime());

        $timeStamp = strtotime($createDate);
        $valid_mime_types = array(
            "image/gif",
            "image/png",
            "image/jpeg",
            "image/pjpeg",
        );

        $dirPath = "/images/place-photo/";
        $iconDirPath = "/images/place-icon/";
        $twig = $this->container->get('twig');
        $globals = $twig->getGlobals();

        $rootDir = $globals['image_real_path'];
        $destination = $rootDir . $dirPath;
        $iconDestination = $rootDir . $iconDirPath;

        if (!is_null($placePhoto)) {
            $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

            if ($photoUrl !== false) {
                $place->setPhoto($photoUrl);
            } else {
                if (!file_exists($rootDir . $dirPath)) {
                    mkdir($destination, 0777, true);
                }

                if (in_array($_FILES['updateplace']['type']['photo'], $valid_mime_types)) {
                    $ext = explode('.', $_FILES['updateplace']['name']['photo']);
                    $ext = end($ext);
                    $filePath = $destination . $place->getId() . "." . $ext;
//                    move_uploaded_file($_FILES['updateplace']['tmp_name']['photo'], $filePath);
                    $this->imageResize(320, 130, $_FILES['updateplace']['tmp_name']['photo'], $filePath);
                }

                $place->setPhoto($dirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
            }
        }
        if (!is_null($placeIcon)) {
            $iconUrl = filter_var($placeIcon, FILTER_VALIDATE_URL);

            if ($iconUrl !== false) {
                $place->setIcon($iconUrl);
            } else {
                if (!file_exists($rootDir . $iconDirPath)) {
                    mkdir($iconDestination, 0777, true);
                }

                if (in_array($_FILES['updateplace']['type']['icon'], $valid_mime_types)) {
                    $ext = explode('.', $_FILES['updateplace']['name']['icon']);
                    $ext = end($ext);
                    $filePath = $iconDestination . $place->getId() . "." . $ext;
//                    move_uploaded_file($_FILES['updateplace']['tmp_name']['icon'], $filePath);
                    $this->imageResize(71, 71, $_FILES['updateplace']['tmp_name']['icon'], $filePath);
                }

                $place->setIcon($iconDirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
            }
        }

        $dm->persist($place);
        $dm->flush();

        return $place;
    }

    /**
     * @Route("/photolist/1", defaults={"page" = 1}, name="manage_photo")
     * @Route("/photolist/{page}", name="manage_photo")
     * @param $page
     * @Template()
     */
    public function photoListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());
        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');


            $qb = $dm->createQueryBuilder('AdminUserBundle:Photo');

            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();

            return $this->render('AdminUserBundle:AdminUser:photolist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * DELETE /photo/{id}
     * @param $id
     **/
    public function deletePhotoAction($id)
    {

        if ($this->get('session')->get('user')->getId()) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $entity = $dm->getRepository('AdminUserBundle:Photo')->findOneBy(array('_id' => $id));
            try {
                $dm->remove($entity);
                $dm->flush();
                $this->get('session')->setFlash('notice', 'Deleted Successfully!');
                return $this->redirect('../photolist/1');

            } catch (\Exception $e) {
                $this->get('session')->setFlash('notice', 'Not Deleted!');
                return $this->redirect('../photolist/1');
            }
        }

    }

    /**
     * @param $lat
     * @param $lng
     * @Template()
     */
    public function getAddressAction($lat, $lng)
    {
        // set your API key here
        $api_key = "AIzaSyD_R73_cR92W83gUHkiqw35-yO4erVYsaw";
        // format this string with the appropriate latitude longitude
//        $url = 'http://maps.google.com/maps/geo?q=' . $lat . ',' . $lng . '&output=json&sensor=true_or_false&key=' . $api_key;

//        $url = 'http://maps.google.com/maps/geo?q=' . $lat . ',' . $lng . '&output=json&sensor=true';
        $url = 'http://maps.googleapis.com/maps/api/geocode/json?latlng=' . $lat . ',' . $lng . '&sensor=false';
        // make the HTTP request
        $data = @file_get_contents($url);
        // parse the json response
        $jsondata = json_decode($data, true);
        // if we get a placemark array and the status was good, get the addres
//        if (is_array($jsondata) && $jsondata ['Status']['code'] == 200) {
//            $address = $jsondata ['Placemark'][0]['address'];
//        }

        if (is_array($jsondata) && !empty($jsondata ['results'][0]['formatted_address'])) {
            $address = $jsondata ['results'][0]['formatted_address'];
        } else {
            $address = "";
        }

        echo $address;
        exit;
    }

    /**
     * @Route("/eventlist/1", defaults={"page" = 1}, name="event_list")
     * @Route("/eventlist/{page}", name="event_list")
     * @param $page
     * @Template()
     */
    public function eventListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());
        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $qb = $dm->createQueryBuilder('AdminUserBundle:Event');

            $adapter = new DoctrineODMMongoDBAdapter($qb);
            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();

            return $this->render('AdminUserBundle:AdminUser:eventlist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * DELETE /event/{id}
     * @param $id
     **/
    public function deleteEventAction($id)
    {

        if ($this->get('session')->get('user')->getId()) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            $entity = $dm->getRepository('AdminUserBundle:Event')->findOneBy(array('_id' => $id));
            try {
                $dm->remove($entity);
                $dm->flush();
                $this->get('session')->setFlash('notice', 'Deleted Successfully!');
                return $this->redirect('../eventlist/1');

            } catch (\Exception $e) {
                $this->get('session')->setFlash('notice', 'Not Deleted!');
                return $this->redirect('../eventlist/1');
            }
        }

    }

    /**
     * @Route("/blockuserlist/1", defaults={"page" = 1}, name="user_block_list")
     * @Route("/blockuserlist/{page}", name="user_block_list")
     * @param $page
     * @Template()
     */
    public function userBlockListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            $qb = $dm->createQueryBuilder('AdminUserBundle:User');
            $qb->addOr($qb->expr()->field('enabled')->equals(false));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:userblocklist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * @Route("/placesearchresult/1", defaults={"page" = 1}, name="manage_place_paginated")
     * @Route("/placesearchresult/{page}", name="manage_place_paginated")
     * @param $page
     * @Template()
     */
    public function searchPlaceAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {

            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:Place');
            $qb->addOr($qb->expr()->field('category')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('title')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('description')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:placesearchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    /**
     * @Route("/photoearchresult/1", defaults={"page" = 1}, name="manage_photo_search")
     * @Route("/photoearchresult/{page}", name="manage_photo_search")
     * @param $page
     * @Template()
     */
    public function searchPhotoAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {

            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:Photo');
            $qb->addOr($qb->expr()->field('title')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('description')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:photosearchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    /**
     * @Route("/event_search_result/1", defaults={"page" = 1}, name="event_search_result")
     * @Route("/event_search_result/{page}", name="event_search_result")
     * @param $page
     * @Template()
     */
    public function searchEventAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {

            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:Event');
            $qb->addOr($qb->expr()->field('title')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('eventShortSummary')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('description')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:eventsearchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    /**
     * @param $page
     * @Template()
     */
    public function blockSearchResultAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');
            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:User');
            $qb->field('enabled')->equals(false);
            $qb->addOr($qb->expr()->field('firstName')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('lastName')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('email')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:blockusersearchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    /**
     * @Route("/customplacelist/1", defaults={"page" = 1}, name="manage_custom_place")
     * @Route("/customplacelist/{page}", name="manage_custom_place")
     * @param $page
     * @Template()
     */
    public function customPlaceListAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {
            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            $qb = $dm->createQueryBuilder('AdminUserBundle:Place');
            $qb->addOr($qb->expr()->field('type')->equals('custom_place'));

            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();

            return $this->render('AdminUserBundle:AdminUser:customplacelist.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        } else {
            $this->get('session')->setFlash('notice', 'You are not authorize!');
            return $this->redirect('login');
        }
    }

    /**
     * @Route("/customplacesearchresult/1", defaults={"page" = 1}, name="manage_custom_place_paginated")
     * @Route("/customplacesearchresult/{page}", name="manage_custom_place_paginated")
     * @param $page
     * @Template()
     */
    public function searchCustomPlaceAction($page = 1)
    {
        $request = $this->get('request');
        $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\SearchUserType());

        if ($this->get('session')->get('user')) {

            $dm = $this->get('doctrine.odm.mongodb.document_manager');

            if ('POST' == $request->getMethod()) {
                $form->bindRequest($request);
                $postData = $form->getData();
                if (!empty($postData['keyword'])) {
                    $postData['keyword'] = strtolower($postData['keyword']);
                }
                $filterBy = $postData['keyword'];
                $this->get('session')->set('filterBy', $filterBy);

            } else {
                $filterBy = $this->get('session')->get('filterBy');
            }
            $qb = $dm->createQueryBuilder('AdminUserBundle:Place');
            $qb->addOr($qb->expr()->field('type')->equals('custom_place'));
            $qb->addOr($qb->expr()->field('category')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('title')->equals(new \MongoRegex("/{$filterBy}/i")))
                ->addOr($qb->expr()->field('description')->equals(new \MongoRegex("/{$filterBy}/i")));
            $adapter = new DoctrineODMMongoDBAdapter($qb);

            $pagerfanta = new Pagerfanta($adapter);
            $pagerfanta->setMaxPerPage(20);

            $pagerfanta->setCurrentPage($page);
            $entities = $pagerfanta->getCurrentPageResults();
            return $this->render('AdminUserBundle:AdminUser:customplacesearchresult.html.twig', array(
                'form' => $form->createView(),
                'entities' => $entities,
                'pager' => $pagerfanta,
            ));
        }
    }

    public function imageResize($maxWidth, $maxHeight, $image, $filePath, $original = null)
    {
        $image_info = getimagesize($image);
        $image_type = $image_info[2];
        if ($image_type == IMAGETYPE_JPEG) {

            $image = imagecreatefromjpeg($image);
        } elseif ($image_type == IMAGETYPE_GIF) {

            $image = imagecreatefromgif($image);
        } elseif ($image_type == IMAGETYPE_PNG) {

            $image = imagecreatefrompng($image);
        }
        // Get current dimensions
        $oldWidth = imagesx($image);
        $oldHeight = imagesy($image);

        // Calculate the scaling we need to do to fit the image inside our frame
        $scale = min($maxWidth / $oldWidth, $maxHeight / $oldHeight);

        // Get the new dimensions
        $newWidth = ceil($scale * $oldWidth);
        $newHeight = ceil($scale * $oldHeight);

        // Create new empty image
        $new = imagecreatetruecolor($newWidth, $newHeight);

        // Resize old image into new
        imagecopyresampled($new, $image,
            0, 0, 0, 0,
            $newWidth, $newHeight, $oldWidth, $oldHeight);

        // Catch the imagedata
        imagejpeg($new, $filePath, 100);

        // Destroy resources
        if ($original == 1)
            imagedestroy($image);
        imagedestroy($new);
    }
}