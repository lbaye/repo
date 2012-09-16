<?php

namespace Event;

use Repository\UserRepo as UserRepository;

class TestEvent extends Base
{
    /**
     * @var UserRepository
     */
    protected $userRepository;

    protected function setFunction()
    {
        $this->function = 'test_event';
    }

    public function run(\GearmanJob $job)
    {
        $workload = json_decode($job->workload());

        file_put_contents('/tmp/workload.txt', $job->workload());

        $this->runTasks();
    }
}