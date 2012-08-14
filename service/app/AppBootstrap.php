<?php

use Doctrine\Common\ClassLoader,
    Doctrine\Common\Annotations\AnnotationReader,
    Doctrine\ODM\MongoDB\DocumentManager,
    Doctrine\MongoDB\Connection,
    Doctrine\ODM\MongoDB\Configuration,
    Doctrine\ODM\MongoDB\Mapping\Driver\AnnotationDriver,
    Symfony\Component\Yaml\Parser;

class Bootstrap
{
    /**
     * @var DocumentManager
     */
    public $dm;

    /**
     * @var array
     */
    public $conf;

    /**
     * @var array
     */
    public $routes = array();

    public function __construct($env)
    {
        $this->loadConfiguration($env);
        $this->loadDoctrine();
    }

    private function loadConfiguration($env)
    {
        $yaml = new Parser();

        $default = $yaml->parse(file_get_contents(__DIR__ . '/config/config.yml'));
        $environment = $yaml->parse(file_get_contents(__DIR__ . '/config/config_' . $env . '.yml'));

        if (is_array($environment)) {
            $this->conf = array_merge($default, $environment);
        } else {
            $this->conf = $default;
        }

        $fileIterator = new DirectoryIterator(__DIR__ . '/config/routes');

        foreach ($fileIterator as $file) {
            if ($file->isFile()) {
                $routes = $yaml->parse(file_get_contents(__DIR__ . '/config/routes/' . $file->getFilename()));
                $this->routes = array_merge($this->routes, $routes);
            }
        }
    }

    private function loadDoctrine()
    {
        $config = new Configuration();
        $config->setProxyDir(__DIR__ . '/cache');
        $config->setProxyNamespace('Proxies');

        $config->setHydratorDir(__DIR__ . '/cache');
        $config->setHydratorNamespace('Hydrators');
        $config->setDefaultDB($this->conf['mongodb']['database']);
        AnnotationDriver::registerAnnotationClasses();

        $reader = new AnnotationReader();
        $config->setMetadataDriverImpl(new AnnotationDriver($reader, __DIR__ . '/../src/Documents'));

        $dsn = 'mongodb://' . $this->conf['mongodb']['host'] . ':' . $this->conf['mongodb']['port'];
        $this->dm = DocumentManager::create(new Connection($dsn), $config);
    }
}