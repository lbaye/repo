Feature: Users
  In order to get information about other users
  As a service user
  I want to see specific users information, list etc.

#Scenario: Get list of users
#  Given I've already setup user account with "xyz@test.com" and "121212"
#  And I'm logged in through "xyz@test.com" and "121212"
#  And I've already setup user account with "kadfkads@ekldf.com" and "abcd"
#
#  When I'm sending http "GET" request to "/users"
#
#  Then I should see http "200" status
#  And Response should have at least "1" item
#  And Response should have "kadfkads@ekldf.com" in the list


Scenario: Get a specific user from email
  Given I've already setup user account with "xyz@test.com" and "121212"
  And I'm logged in through "xyz@test.com" and "121212"
  And I've already setup user account with "kadfkads@ekldf.com" and "abcd"

  When I'm sending http "GET" request to "/users/email/kadfkads@ekldf.com"

  Then I should see http "200" status
  And Response should have at least "1" item
  And Response should have "kadfkads@ekldf.com" in the list

Scenario: Get a specific user by id
  Given I've already setup user account with "xyz@test.com" and "121212"
  And I'm logged in through "xyz@test.com" and "121212"
  And I've already setup user account with "kadfkads@ekldf.com" and "abcd"

  When I'm fetching the user id from "kadfkads@ekldf.com" and "abcd"

  Then Response's email attribute should be equal to "kadfkads@ekldf.com"

Scenario: Get information about self
  Given I've already setup user account with "xyz@test.com" and "121212"
  And I'm logged in through "xyz@test.com" and "121212"

  When I'm sending http "GET" request to "/me"

  Then I should see http "200" status
  And Response should have "xyz@test.com" in the list


