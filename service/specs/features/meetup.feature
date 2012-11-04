Feature: Meet up
  In order to create meetup event with other users
  As a service user
  I want to create/delete/update meetups


  Scenario: Create Meet up
    Given I've already setup user account with "xyz@test.com" and "121212"
    And I've already setup user account with "test@example.com" and "abcd"
    And I'm fetching the user id from "test@example.com" and "abcd"
    And I'm logged in through "xyz@test.com" and "121212"

    When I'm sending http "POST" request to "/meetups"
    And I'm posting "message=You are invited to,permission=public,lat=23.30,lng=23.30" to create a meet up inviting a guest

    Then I should see http "201" status
    And Response should have "guests" attribute
    And Response should have "message" attribute
    And Response should have the invited guest id in guests list

  Scenario: Get list of Meetups
    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"

    When I'm sending http "GET" request to "/meetups"

    Then I should see http "200" status
    And Response should have at least "1" item

  Scenario: Get individual Meet ups

    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"

    When I'm fetching the created Meetup

    Then I should see http "200" status
    And Response's id should match Meetup id


  Scenario: Get list of a specific users Meet up

    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"
    And I'm logged in through "test@example.com" and "abcd"

    When I'm fetching the user id from "xyz@test.com" and "121212"
    And I'm fetching the users meetup list
    
    Then I should see http "200" status


  Scenario: Get list of Meetups created by self
    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"

    When I'm sending http "GET" request to "/me/meetups"
    
    Then I should see http "200" status
    And Response should have at least "1" item

  Scenario: Update a Meetup by changing message
    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"

    When I'm sending http "PUT" request to "/meetups/{last_meetup_id}"
    And I'm posting "message=Changed message"
    
    Then I should see http "200" status
    And Response's "message" attribute should be equal to "Changed message"

  Scenario: Delete a Meetup

    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"
    
    When I'm sending http "DELETE" request to "/meetups/{last_meetup_id}"
    
    Then I should see http "200" status
    And Response's "message" attribute should be equal to "Deleted Successfully"

  Scenario: Set rsvp to yes for a Meetup
    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"
    And I'm logged in through "test@example.com" and "abcd"

    When I'm sending http "PUT" request to "/meetups/{last_meetup_id}/rsvp"
    And I'm posting "response=yes"
    
    Then I should see http "200" status
    And Response's rsvp "yes" should contain the user id of "test@example.com" and "abcd"
    
  Scenario: Get Invited List
    Given I have created meetup with "xyz@test.com" and "121212" and invited "test@example.com" and "abcd"
    And I'm logged in through "test@example.com" and "abcd"
    
    When I'm sending http "GET" request to "/meetups/invited"
    
    Then I should see http "200" status
    And Response should contain the meetup just created





