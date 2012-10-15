When /^I'm sending friend request with "(.*?)"$/ do |str_params|
  @response = @client.send(:post, "/request/friend/#{@user_id}")
  @response.set_params(Util::Params.parse(str_params))

  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end
  @response.code
end


Then /^Response's "(.*?)" attribute should be equal to "(.*?)"$/ do |attr, value|
  res = @response.json
  res[attr].should == value
  res['userId'].should ==  @authResponse['id']
end


Given /^I receive a friend request from "([^"]*)" and "([^"]*)" with "([^"]*)"$/ do |email, password, str_params|

  email = @rand_email if email == "{get_rand_email}"

  @response = @client.send(:post, "/request/friend/#{@authResponse['id']}")
  @response.set_params(Util::Params.parse(str_params))
  auth = Util::Params::Functions.authenticate(email, password)
  @response.set_headers('Auth-Token' => auth['authToken'])
  @response.code
end

When /^I'm fetching the friend request id$/ do
  @friend_request_id = @response.json['id']
end

Then /^Response should have correct friend request id$/ do
  res = @response.json
  if res.is_a? Hash
    res["id"].should == @friend_request_id
  else
    valid = false
    res.each do |friend_request|
      valid = true if friend_request["id"] == @friend_request_id
    end
    valid.should == true
  end
end


When /^I'm accepting the friend request$/ do
  @response = @client.send(:put, "/request/friend/#{@user_id}/accept")

  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end

  @response.code

end

