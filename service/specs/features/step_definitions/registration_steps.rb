Then /^I should be warned "([^"]*)" account is already occupied.$/ do |email|
  @response.response.body.should match /{\"result\":\"A resource with the identifier #{email} already exist.\"}/
end