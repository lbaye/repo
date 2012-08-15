<?php

use Doctrine\ODM\MongoDB\DocumentManager;

class GearmanKernel
{
    /**
     * @var array
     */
    protected $conf;

    /**
     * @var GearmanWorker
     */
    protected $worker;

    /**
     * @var array
     */
    protected $services;

    public function __construct(DocumentManager $dm, $conf = array())
    {
        $this->conf = $conf;
        $this->services['dm'] = $dm;

        $this->prepare();
    }

    public function prepare()
    {
        $this->setupGearman();
        $this->registerWorkers();
        $this->initializeTemplating();
        $this->initializeMailer();
    }

    public function handle()
    {
        while (1) {

            print "Waiting for job...\n";
            $ret = $this->worker->work();

            if ($this->worker->returnCode() != GEARMAN_SUCCESS) {
                break;
            }
        }
    }

    private function setupGearman()
    {
        $this->worker = new GearmanWorker();
        $this->worker->addServer($this->conf['gearman']['host'], $this->conf['gearman']['port']);
    }

    private function registerWorkers()
    {
        $dirIterator = new DirectoryIterator(__DIR__ . '/../src/Event');

        foreach ($dirIterator as $file) {
            if ($file->isFile()) {
                $eventClass = 'Event\\' . $file->getBasename('.php');
                if ($eventClass != 'Event\Base') {
                    $workerObject = new $eventClass($this->conf, $this->services);
                    $this->worker->addFunction($workerObject->getFunction(), array($workerObject, 'run'));
                }
            }
        }

    }

    private function initializeTemplating()
    {
        $twigLoader = new Twig_Loader_Filesystem(__DIR__ . '/../src/Views');
        $this->services['twig'] = new Twig_Environment($twigLoader, array('cache' => __DIR__ . '/cache/twig'));
    }

    private function initializeMailer()
    {
        $host     = $this->conf['swiftmailer']['host'];
        $username = $this->conf['swiftmailer']['username'];
        $password = $this->conf['swiftmailer']['password'];
        $port     = $this->conf['swiftmailer']['port'];

        $transport = Swift_SmtpTransport::newInstance($host, $port);
        $transport->setUsername($username);
        $transport->setPassword($password);

        $this->services['mailer'] = Swift_Mailer::newInstance($transport);
    }

}