Feature: Search
  In order to find people/location
  As a service user
  I want to search for people and places

  Scenario: Generic search
    Given I've already setup user account with "test@example.com" and "abcd"
    And I'm logged in through "test@example.com" and "abcd"


    When I'm sending http "POST" request to "/search"
    And I'm posting "lat=23.0,lng=23.0"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have "people" attribute
    And Response should have "places" attribute
    And Response should have "facebookFriends" attribute

  Scenario: People search
    Given I've already setup user account with "rgb@example.com" and "abcd"
    And I'm logged in through "rgb@example.com" and "abcd"


    When I'm sending http "POST" request to "/search/people"
    And I'm posting "lat=23.0,lng=23.0"

    Then I should see http "200" status
    And Response is valid "application/json" formatted
    And Response should have "id" attribute
