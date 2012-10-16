Feature: Messaging
  In order to establish communication among two or more SM users
  As a web service user
  I want to send message with single or multiple recipients.

  Scenario: Create new message
    Given I've already setup user account with "test@example.com" and "abcd"
    And I'm logged in through "test@example.com" and "abcd"

    When I'm sending http "POST" request to "/messages"
    And I'm posting "subject=Hi, content=Hello world, recipients[]={create_user['id']}"

    Then I should see http "201" status
    And Response is valid "application/json" formatted

  Scenario: Create reply under message
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Anderson, content=Hello world" and recipients as "me"

    When I'm creating message with thread_id

    Then I should see http "201" status
    And Response is valid "application/json" formatted
    And Response should have "thread" attribute

  Scenario: List of incoming messages (inbox)
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Anderson, content=Hello world" and recipients as "me"

    When I'm sending http "GET" request to "/messages/inbox"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "Hello Anderson"

  Scenario: List of sent messages
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Sentous, content=Hello world" and recipients as "me"

    When I'm sending http "GET" request to "/messages/sent"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "Hello Sentous"

  Scenario: Delete message
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Deletous, content=Hello world" and recipients as "me"

    When I'm sending http "DELETE" request to "/messages/{msg_last_id}"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have at least "1" item
    And Response should match "{\"message\":\"Removed successfully\"}"

  Scenario: Inbox should be ordered by update date
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created several messages
    And I've sent few update requests through updating status

    When I'm sending http "GET" request to "/messages/inbox"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Messages are ordered by updating date

  Scenario: Add recipient to an existing message thread
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Hi, content=Hello world" and recipients as "me"

    When I'm sending http "POST" request to "/messages/{msg_last_id}/recipients"
    And I'm posting "recipients[]={create_user['id']}, recipients[]={create_user['id']}"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Two recipients are added in the list

#  Scenario: Mark message as read
#    Given I've already setup user account with "xyz@test.com" and "121212"
#    And I'm logged in through "xyz@test.com" and "121212"
#    And I've created a message with "subject=Hello Hi, content=Hello world" and recipients as "me"
#
#    When I'm sending http "POST" request to "/messages/{msg_last_id}/status/read"
#
#    Then I should see http "200" status
#    And Response is valid "application/json" formatted
#    And Response should match "\"status\":\"read\""

  Scenario: Mark message as unread
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Hi, content=Hello world" and recipients as "me"

    When I'm sending http "POST" request to "/messages/{msg_last_id}/status/unread"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should match "\"status\":\"unread\""

  @focus
  Scenario: Retrieve message replies from specific time
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I'm logged in through "xyz@test.com" and "121212"
    And I've created a message with "subject=Hello Hi, content=Hello world" and recipients as "me"
    And I've added several message replies

    When I'm sending http "GET" request to "/messages/{msg_last_id}/replies?since=eval(Util::Params::Functions.since_two_day)"

    Then I should see http "200" status
    And Response is valid "application/json" formatted







