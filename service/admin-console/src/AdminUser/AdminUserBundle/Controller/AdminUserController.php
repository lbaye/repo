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
        return array();
    }

    /**
     * @Route("/login", name="adminuser_login")
     * @Template()
     */
    public function loginAction()
    {
        $form = $this->get('form.factory')->create(new LoginType());

        $request = $this->get('request');

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

        if ($this->get('session')->get('user')->getId()) {
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

                return $this->redirect('../userlist');
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

        if ($this->get('session')->get('user')->getId()) {
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
                    return $this->redirect('../userlist');
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
            $message = \Swift_Message::newInstance()
                ->setSubject($subject)
                ->setFrom($this->container->getParameter('sender_email'))
                ->setTo($entity->getEmail())
                ->setBody($this->renderView('AdminUserBundle:AdminUser:user.email.txt.twig',
                array('entity' => $entity, 'postData' => $messageData)));
            $this->get('mailer')->send($message);
            $this->get('session')->setFlash('notice', 'Message sent successfully!');
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

        if ($this->get('session')->get('user')->getId()) {
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

                    if (!empty($postData['icon'])) {
                        $placeIcon = $postData['icon'];
                    }

                    if (!empty($postData['photo'])) {
                        $this->savePlacePhoto($this->document->getId(), $postData['photo'], $postData['createDate'], $placeIcon);
                    }

                    $this->get('session')->setFlash('notice', 'Place added successfully!');
                    return $this->redirect('placelist');
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
            $form = $this->get('form.factory')->create(new \AdminUser\AdminUserBundle\Form\UpdatePlaceType(), $entity);

            if ($request->getMethod() === 'POST') {
                $form->bindRequest($request);
                $postData = $form->getData();

                if ($form->isValid()) {

                    $newLocation['lat'] = floatval($postData->getLat());
                    $newLocation['lng'] = floatval($postData->getLng());
                    $newLocation['address'] = $postData->getAddress();
                    $postData->setLocation($newLocation);

                    $dm->persist($postData);
                    $dm->flush();

                    $existPlaceIcon = $postData->getIcon();
                    $existPlacePhoto = $postData->getPhoto();

                    if (!empty($existPlaceIcon)) {
                        $placeIcon = $postData->getIcon();
                    }

                    if (!empty($existPlacePhoto)) {
                        $this->updatePlacePhoto($id, $postData->getPhoto(), date('Y-m-d h:i:s a', time()), $placeIcon);
                    }

                    $this->get('session')->setFlash('notice', 'Place updated successfully!');
                    return $this->redirect('placelist');
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
        $rootDir = __DIR__ . '/../../../../../web';
        $destination = $rootDir . "/" . $dirPath;
        $iconDestination = $rootDir . "/" . $iconDirPath;

        $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $place->setPhoto($photoUrl);
        } else {
            if (!file_exists($rootDir . "/" . $dirPath)) {
                mkdir($destination, 0777, true);
            }

            if (in_array($_FILES['addplace']['type']['photo'], $valid_mime_types)) {
                $ext = explode('.', $_FILES['addplace']['name']['photo']);
                $ext = end($ext);
                $filePath = $destination . $place->getId() . "." . $ext;
                move_uploaded_file($_FILES['addplace']['tmp_name']['photo'], $filePath);
            }

            $place->setPhoto($dirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
        }
        if (!is_null($placeIcon)) {
            $iconUrl = filter_var($placeIcon, FILTER_VALIDATE_URL);

            if ($iconUrl !== false) {
                $place->setIcon($iconUrl);
            } else {
                if (!file_exists($rootDir . "/" . $iconDirPath)) {
                    mkdir($iconDestination, 0777, true);
                }

                if (in_array($_FILES['addplace']['type']['icon'], $valid_mime_types)) {
                    $ext = explode('.', $_FILES['addplace']['name']['icon']);
                    $ext = end($ext);
                    $filePath = $iconDestination . $place->getId() . "." . $ext;
                    move_uploaded_file($_FILES['addplace']['tmp_name']['icon'], $filePath);
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
        $rootDir = __DIR__ . '/../../../../../web';
        $destination = $rootDir . "/" . $dirPath;
        $iconDestination = $rootDir . "/" . $iconDirPath;

        $photoUrl = filter_var($placePhoto, FILTER_VALIDATE_URL);

        if ($photoUrl !== false) {
            $place->setPhoto($photoUrl);
        } else {
            if (!file_exists($rootDir . "/" . $dirPath)) {
                mkdir($destination, 0777, true);
            }

            if (in_array($_FILES['updateplace']['type']['photo'], $valid_mime_types)) {
                $ext = explode('.', $_FILES['updateplace']['name']['photo']);
                $ext = end($ext);
                $filePath = $destination . $place->getId() . "." . $ext;
                move_uploaded_file($_FILES['updateplace']['tmp_name']['photo'], $filePath);
            }

            $place->setPhoto($dirPath . $place->getId() . "." . $ext . "?" . $timeStamp);
        }
        if (!is_null($placeIcon)) {
            $iconUrl = filter_var($placeIcon, FILTER_VALIDATE_URL);

            if ($iconUrl !== false) {
                $place->setIcon($iconUrl);
            } else {
                if (!file_exists($rootDir . "/" . $iconDirPath)) {
                    mkdir($iconDestination, 0777, true);
                }

                if (in_array($_FILES['updateplace']['type']['icon'], $valid_mime_types)) {
                    $ext = explode('.', $_FILES['updateplace']['name']['icon']);
                    $ext = end($ext);
                    $filePath = $iconDestination . $place->getId() . "." . $ext;
                    move_uploaded_file($_FILES['updateplace']['tmp_name']['icon'], $filePath);
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
        if ($this->get('session')->get('user')->getId()) {
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
        $url = 'http://maps.google.com/maps/geo?q=' . $lat . ',' . $lng . '&output=json&sensor=true_or_false&key=' . $api_key;
        // make the HTTP request
        $data = @file_get_contents($url);
        // parse the json response
        $jsondata = json_decode($data, true);
        // if we get a placemark array and the status was good, get the addres
        if (is_array($jsondata) && $jsondata ['Status']['code'] == 200) {
            $address = $jsondata ['Placemark'][0]['address'];
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
        if ($this->get('session')->get('user')->getId()) {
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

        if ($this->get('session')->get('user')->getId()) {
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

        if ($this->get('session')->get('user')->getId()) {

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

        if ($this->get('session')->get('user')->getId()) {

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

        if ($this->get('session')->get('user')->getId()) {

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

        if ($this->get('session')->get('user')->getId()) {
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
}