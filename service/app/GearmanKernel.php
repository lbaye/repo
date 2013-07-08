<?php

use Doctrine\ODM\MongoDB\DocumentManager,
    Helper\Dependencies;

class GearmanKernel {
    /**
     * @var array
     */
    protected $conf;

    /**
     * @var GearmanWorker
     */
    protected $worker;

    private $logger;

    /**
     * @var array
     */
    protected $services;

    private $eventType = null;

    public function __construct(DocumentManager $dm, $conf = array(), $pLogger = null, $eventType = null) {
        $this->conf = $conf;
        $this->services['dm'] = $dm;
        $this->logger = $pLogger;
        $this->eventType = $eventType;

        $this->prepare();

        // @TODO : Replace with a DIC
        Dependencies::$dm = $this->services['dm'];
    }

    public function prepare() {
        $this->setupGearman();
        $this->registerWorkers();
        $this->initializeTemplating();
        //$this->initializeMailer();
    }

    public function handle() {
        while (1) {

            print "Waiting for job...\n";
            $ret = $this->worker->work();

            if ($this->worker->returnCode() != GEARMAN_SUCCESS) {
                break;
            }
        }
    }

    private function setupGearman() {
        $this->worker = new \GearmanWorker();
        $this->worker->addServer($this->conf['gearman']['host'], $this->conf['gearman']['port']);
    }

    /**
     * Register worker's event based on ARGUMENTS.
     *
     * If no event type is specified worker will be responsible for all incoming events.
     * Otherwise this worker will be responsible for a specific event. (which is set over command args)
     *
     * For example -
     *      $ <worker command> <stage> <EventName>
     */
    private function registerWorkers() {
        if ($this->eventType == null) {
            $dirIterator = new DirectoryIterator(__DIR__ . '/../src/Event');

            foreach ($dirIterator as $file) {
                if ($file->isFile()) {
                    $eventClass = 'Event\\' . $file->getBasename('.php');
                    $this->registerEventClass($eventClass);
                }
            }
        } else {
            $eventClasses = explode('|', $this->eventType);
            foreach ($eventClasses as $eventClass)
                $this->registerEventClass($eventClass);
        }
    }

    private function registerEventClass($eventClass) {
        if ($eventClass != 'Event\Base') {
            $this->getLogger()->info("Registering event - $eventClass");
            $workerObject = new $eventClass($this->conf, $this->services);
            $workerObject->setLogger($this->getLogger());
            $this->worker->addFunction($workerObject->getFunction(), array($workerObject, 'run'));
        }
    }

    private function initializeTemplating() {
        $twigLoader = new Twig_Loader_Filesystem(__DIR__ . '/../src/Views');
        $this->services['twig'] = new Twig_Environment($twigLoader, array('cache' => __DIR__ . '/cache/twig'));
    }

    private function initializeMailer() {
        $host = $this->conf['swiftmailer']['host'];
        $username = $this->conf['swiftmailer']['username'];
        $password = $this->conf['swiftmailer']['password'];
        $port = $this->conf['swiftmailer']['port'];

        $transport = Swift_SmtpTransport::newInstance($host, $port);
        $transport->setUsername($username);
        $transport->setPassword($password);

        $this->services['mailer'] = Swift_Mailer::newInstance($transport);
    }

    public function setLogger($logger) {
        $this->logger = $logger;
    }

    public function getLogger() {
        return $this->logger;
    }

}