Feature: User Registration
  In order to add new user to the system
  As a web service user
  I want to register user

  @email

  Scenario: Registration without email
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "firstName=abcd, lastName=adss, password=abcdef, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"message\":\"`email` is required field.\"}"

  Scenario: Registration without firstName
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email={rand_email}, lastName=adss, password=abcdef, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"message\":\"`firstName` is required field.\"}"

  Scenario: Registration without avatar
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email={rand_email}, firstName=abcd, lastName=adss, password=abcdef"

    Then I should see http "406" status
    And Response should match "{\"message\":\"`avatar` is required field.\"}"


  Scenario: Registration without password
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email={rand_email}, firstName=abcd, lastName=adss, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"message\":\"`password` is required field.\"}"

  Scenario: Registration with blank password
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email=astring@anotherstring, firstName=abcd, lastName=adss, password=, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"result\":\"Invalid request\"}"


  Scenario: Registration with invalid email address
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email=astring@anotherstring, firstName=abcd, lastName=adss, password=abcdef, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"result\":\"Invalid request\"}"

  Scenario: Registration with invalid email address
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email=astring@anot@herstring.com, firstName=abcd, lastName=adss, password=abcdef, avatar=www.google.com/dkd"

    Then I should see http "406" status
    And Response should match "{\"result\":\"Invalid request\"}"

  Scenario: Registration with required parameters (email, password, firstName, lastName, avatar)
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email={rand_email}, firstName=abcd, lastName=adss, password=abcdef, avatar=www.google.com/dkd"

    Then I should see http "201" status
    And Response is valid "application/json" formatted

  Scenario: Registration with Facebook
    When I'm sending http "POST" request to "/auth/login/fb"
    And I'm posting "email={rand_email}, facebookAuthToken=2323233, facebookId=32323"
    Then I should see http "200" status
    And Response is valid "application/json" formatted

  Scenario: Registration with an existing email
    Given I've already setup user account with "ahmed.tanvir@genweb2.com" and "121212"
    When I'm sending http "POST" request to "/auth/registration"
    And I'm posting "email=ahmed.tanvir@genweb2.com, firstName=abcd, lastName=adss, password=abcdef, avatar=www.google.com/dkd"
    Then I should be warned "ahmed.tanvir@genweb2.com" account is already occupied.

  Scenario: Registration with facebook when an account exists with same email
    pending