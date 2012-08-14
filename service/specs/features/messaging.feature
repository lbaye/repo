@focus
Feature: Messaging
  In order to establish communication among two or more SM users
  As a web service user
  I want to send message with single or multiple recipients.

  Scenario: Create new message
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"

    When I'm sending http "POST" request to "/messages"
    And I'm posting "subject=Hi, content=Hello world, recipients[]={create_user['id']}"

    Then I should see http "201" status
    And Response is valid "application/json" formatted

  Scenario: Create reply under message
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"
    And I've created a message with "subject=Hello Anderson, content=Hello world" and recipients as "me"

    When I'm creating message with thread_id

    Then I should see http "201" status
    And Response is valid "application/json" formatted
    And Response should have "thread" attribute

  Scenario: List of incoming messages (inbox)
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"
    And I've created a message with "subject=Hello Anderson, content=Hello world" and recipients as "me"

    When I'm sending http "GET" request to "/messages/inbox"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "Hello Anderson"

  Scenario: List of sent messages
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"
    And I've created a message with "subject=Hello Sentous, content=Hello world" and recipients as "me"

    When I'm sending http "GET" request to "/messages/sent"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "Hello Sentous"

  Scenario: Delete message
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"
    And I've created a message with "subject=Hello Deletous, content=Hello world" and recipients as "me"

    When I'm sending http "DELETE" request to "/messages/{msg_last_id}"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "{\"message\":\"Removed Successfully\"}"

  Scenario: List of incoming messages should not include replies
    Given I've already setup user account with "test@email.com" and "abcdef"
    And I'm logged in through "test@email.com" and "abcdef"
    And I've created a message with "subject=Hello 1, content=Hello world" and recipients as "me"

    When I'm sending http "GET" request to "/messages/sent"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response array of hashes should not have "thread" attribute

  Scenario: List of incoming messages should be ordered by last replay's update date



