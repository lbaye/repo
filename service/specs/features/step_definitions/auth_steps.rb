Given /^I've already setup user account with "([^"]*)" and "([^"]*)"$/ do |email, password|
  response = @client.send(:post, '/auth/registration')
  response.set_params({email: email, password: password, firstName: "ab", lastName: "cd", avatar:"www.google.com/xyx"})
end


When /^I'm logged in through "([^"]*)" and "([^"]*)"$/ do |email, password|
  @authResponse = Util::Params::Functions.authenticate(email, password)
end