Feature: Other Routes
   In order to communicate with other users
   As a service user
   I want to send/receive friend requests, notifications and block specific users



Scenario: Sending friend request
  Given I've already setup user account with "{set_rand_email}" and "121212"
  And I've already setup user account with "test@example.com" and "abcd"
  And I'm logged in through "test@example.com" and "abcd"

  When I'm fetching the user id from "{get_rand_email}" and "121212"
  And I'm sending friend request with "message=Test message"

  Then I should see http "200" status
  And Response's "message" attribute should be equal to "Test message"

Scenario: Get friend request
  Given I've already setup user account with "{set_rand_email}" and "121212"
  And I've already setup user account with "test@example.com" and "abcd"
  And I'm logged in through "test@example.com" and "abcd"
  And I receive a friend request from "{get_rand_email}" and "121212" with "message=test test"

  When I'm fetching the friend request id
  And I'm sending http "GET" request to "/request/friend"
  
  Then I should see http "200" status
  And Response should have at least "1" item
  And Response should have correct friend request id

Scenario: Accept friend request
  Given I've already setup user account with "{set_rand_email}" and "121212"
  And I've already setup user account with "test@example.com" and "abcd"
  And I'm logged in through "test@example.com" and "abcd"
  And I receive a friend request from "{get_rand_email}" and "121212" with "message=Accept request"

  And I'm fetching the user id from "{get_rand_email}" and "121212"
  And I'm accepting the friend request
  
  Then I should see http "200" status



  
  





