Feature: Review
  In order to review different venues
  As a web service user
  I want to create,edit, delete and get reviews


Scenario: Creating a review without authenticated user
  When I'm sending http "POST" request to "/reviews"
  And I'm posting "venue={rand_string('venue')}, venueType=facebook, rating=4, review={rand_string('review')}"

  Then I should see http "401" status
  
Scenario: Creating review with authenticated user
  Given I've already setup user account with "xyz@test.com" and "121212"
  And I'm logged in through "xyz@test.com" and "121212"

  When I'm sending http "POST" request to "/reviews"
  And I'm posting "venue={rand_string('venue')}, venueType=facebook, rating=4, review={rand_string('review')}"

  Then I should see http "201" status
  And Response is valid "application/json" formatted


Scenario: Update a review
  Given I've created a review with "xyz@test.com" and "121212" and rating "5"

