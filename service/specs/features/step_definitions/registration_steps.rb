Then /^I should be warned "([^"]*)" account is already occupied.$/ do |email|
  @response.response.body.should match /A resource with the identifier test@email.com already exist/
end