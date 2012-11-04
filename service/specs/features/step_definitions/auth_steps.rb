Given /^I've already setup user account with "([^"]*)" and "([^"]*)"$/ do |email, password|
  if email == "{set_rand_email}"
    @rand_email = email = Util::Params::Functions.rand_email
    #  p @rand_email
  end
  response = @client.send(:post, '/auth/registration')
  response.set_params({email: email, password: password, firstName: "ab", lastName: "cd", avatar: "www.google.com/xxyza"})
  response.code
end


When /^I'm logged in through "([^"]*)" and "([^"]*)"$/ do |email, password|

  if email == "{set_rand_email}"
    @rand_email = email = Util::Params::Functions.rand_email
  end
  @authResponse = Util::Params::Functions.authenticate(email, password)
  #puts "user token of logged in user #{@authResponse['authToken']}"
  #puts "user id of logged in user #{@authResponse['id']}"

end