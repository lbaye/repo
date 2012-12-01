<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class RefreshSearchCache extends Base {
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction() {
        $this->function = 'refresh_search_cache';
    }

    public function __construct($conf, $services) {
        parent::__construct($conf, $services);
        $this->userRepository = $this->services['dm']->getRepository('Document\User');
    }

    public function run(\GearmanJob $job) {
        $this->info("Executing Event::RefreshSearchCache with job - {$job->unique()}");

        $workload = json_decode($job->workload());
        $this->debug('Workload - ' . json_encode($workload));

        $user = $this->userRepository->find($workload->userId);
        if ($user) {
            $this->userRepository->refresh($user);

            $this->debug("RUnn rnn");

            $this->runTasks();
        }
    }
}