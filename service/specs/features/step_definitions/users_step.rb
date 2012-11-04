Then /^Response should have "(.*?)" in the list$/ do |email|
  users = @response.json
  if users.is_a? Hash
    users["email"].should == email
  else
    exists = false
    users.each do |user|
      exists = true if user["email"] == email
    end
    exists.should == true
  end

end

When /^I'm fetching the user id from "(.*?)" and "(.*?)"$/ do |email,password|
  email = @rand_email if email == "{get_rand_email}"
  auth_response = Util::Params::Functions.authenticate(email, password)
  @user_id = auth_response["id"]
end

Then /^Response's email attribute should be equal to "(.*?)"$/ do |email|
  response = @client.send(:get, "/users/#{@user_id}")

  if @authResponse
    response.set_headers('Auth-Token' => @authResponse['authToken'])
  end

  res = response.json

end

