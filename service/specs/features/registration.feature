Feature: User Registration
  In order to add new user to the system
  As a web service user
  I want to register user

  @email
  Scenario: Registration with email and password
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email={rand_email}, password=abcdef"

    Then I should see http "201" status
    And Response is valid "application/json" formatted

  Scenario: Registration with Facebook
    When I'm sending http "POST" request to "/auth/login/fb"
    And I'm posting "email={rand_email}, facebookAuthToken=2323233, facebookId=32323"
    Then I should see http "200" status
    And Response is valid "application/json" formatted

  Scenario: Registration with an existing email
    Given I've already setup user account with "test@email.com" and "abcdef"
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email=test@email.com, password=defsdd"
    Then I should be warned "test@email.com" account is already occupied.

  Scenario: Registration with facebook when an account exists with same email
    pending