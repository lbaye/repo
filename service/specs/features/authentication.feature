Feature: User Authentication
  In order to authenticate user
  As a web service user
  I want to verify user credential

  Scenario: Authenticate user
    Given I've already setup user account with "email=ahmed.tanvir@genweb2.com" and "121212"
    When I'm sending http "POST" request to "/auth/login"
    And I'm posting "email=ahmed.tanvir@genweb2.com, password=121212"
    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should match ""authToken":"

  Scenario: Authenticate with invalid user
    When I'm sending http "POST" request to "/auth/login"
    And I'm posting "email={rand_email}, password=abcdef"
    Then I should see http "404" status
    And Response is valid "application/json" formatted
    And Response should match "{\"result\":\"Not Found\"}"
