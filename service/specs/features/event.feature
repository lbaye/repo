Feature: Events
  In order to use event related functionalities
  As a web service user
  I want to create, update, delete, share and get list of events

  Scenario: Create Event with unauthenticated user
    Given I've already setup user account with "ahmed.tanvir@genweb2.com" and "121212"

    When I'm sending http "POST" request to "/events"
    And I'm posting "title={rand_string('title')}, description={rand_string('description')}, address={rand_string('address')}, lat=1234, lng=4321, time=14.30"

    Then I should see http "401" status


  Scenario: Create Event with authenticated user
    Given I've already setup user account with "ahmed.tanvir@genweb2.com" and "121212"
    And I'm logged in through "ahmed.tanvir@genweb2.com" and "121212"

    When I'm sending http "POST" request to "/events"
    And I'm posting "title={rand_string('title')}, description={rand_string('des')}, address={rand_string('address')}, lat=1234, lng=4321, time=14.30"

    Then I should see http "201" status
    And Response is valid "application/json" formatted

  Scenario: Get all public Events
    Given I've already setup user account with "test@example.com" and "abcd"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=public"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('private-title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=private"
    And I've already setup user account with "ahmed.tanvir@genweb2.com" and "121212"
    And I'm logged in through "ahmed.tanvir@genweb2.com" and "121212"

    When I'm sending http "GET" request to "/events"

    Then I should see http "200" status
    And Response should have at least "1" item
    And Response should not contain any private Events

  Scenario: Get error message while trying to retrieve unauthorized Event
    Given I've already setup user account with "test@example.com" and "abcd"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=private"
    And I've already setup user account with "ahmed.tanvir@genweb2.com" and "121212"
    And I'm logged in through "ahmed.tanvir@genweb2.com" and "121212"

    When I am retrieving the created event

    Then I should see http "403" status
    And Response should match "{\"message\":\"Not permitted for you\"}"


  Scenario: Get a specific Event
    Given I've already setup user account with "test@example.com" and "abcd"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=public"

    When I am retrieving the created event
    Then I should see http "200" status
    And Retrieved Event id should be equal to the created Events id

  Scenario: Retrieve list of my events
    Given I've already setup user account with "test@example.com" and "abcd"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=public"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30, permission=private"

    When I'm sending http "GET" request to "/me/events"

    Then I should see http "200" status
    And Response should have at least "2" item

  Scenario: Update existing Event
    Given I've already setup user account with "test@example.com" and "abcd"
    And An event is created with "test@example.com" and "abcd" with "title={rand_string('title')}, description={rand_string('description')} ,address={rand_string('address')}, lat=1234, lng=4321, time=14.30"
    And I'm logged in through "test@example.com" and "abcd"

    When I change the attribute "title=abcd"

    Then I should see http "200" status
    And Event "title" should be equal to "abcd"



