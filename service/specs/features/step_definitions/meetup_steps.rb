#  @response.set_params(Util::Params.parse(str_params))
When /^I'm posting "(.*?)" to create a meet up inviting a guest$/ do |str_params|
  str_params << ",guests[]=#{@user_id}"
  @response.set_params(Util::Params.parse(str_params))
  #puts @user_id
end

Given /^I have created meetup with "(.*?)" and "(.*?)" and invited "(.*?)" and "(.*?)"$/ do |u_email, u_pass, g_email, g_pass|
  steps %{

    Given I've already setup user account with "#{u_email}" and "#{u_pass}"
    And I've already setup user account with "#{g_email}" and "#{g_pass}"
    And I'm fetching the user id from "#{g_email}" and "#{g_pass}"
    And I'm logged in through "#{u_email}" and "#{u_pass}"

    When I'm sending http "POST" request to "/meetups"
    And I'm posting "message=You are invited to {rand_string('meetup')},permission=public,lat=23.30,lng=23.30 " to create a meet up inviting a guest

    Then I should see http "201" status
    And Response should have "guests" attribute
    And Response should have "message" attribute
    And Response should have the invited guest id in guests list
        }
    @meetup_id = @response.json['id']

end

Then /^Response should have the invited guest id in guests list$/ do
  res = @response.json
  res['guests']['users'].include?(@user_id).should == true
end

When /^I'm fetching the created Meetup$/ do
  @response = @client.send(:get, "/meetups/#{@meetup_id}")

  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end
end



Then /^Response's id should match Meetup id$/ do
  res = @response.json
  res['id'].should == @meetup_id
end


When /^I'm fetching the users meetup list$/ do

  @response = @client.send(:get, "/users/#{@user_id}/meetups")

  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end

end

Then /^Response's rsvp "(.*?)" should contain the user id of "(.*?)" and "(.*?)"$/ do |value, email, password|
  res = @response.json
  auth = Util::Params::Functions.authenticate(email, password)
  user_id = auth["id"]
  res['rsvp'][value].include?(user_id).should == true
end


Then /^Response should contain the meetup just created$/ do
  res = @response.json
  if res.is_a? Hash
    res['id'].should == @meetup_id
  else
    valid = false
    res.each do |meetup|
     valid = true if meetup['id'] == @meetup_id
    end
    valid.should == true
  end
end