Given /^I've created a review with "(.*?)" and "(.*?)" and rating "(.*?)"$/ do |email, password, rating|
  steps %{
    Given I've already setup user account with "#{email}" and "#{email}"
    And I'm logged in through "#{email}" and "#{email}"

    When I'm sending http "POST" request to "/reviews"
    And I'm posting "venue={rand_string('venue')}, venueType=facebook, rating=4, review={rand_string('review')}"

    Then I should see http "201" status
    And Response is valid "application/json" formatted
        }
end