Given /^An event is created with "([^"]*)" and "([^"]*)" with "([^"]*)"$/ do |email, password, str_params|
  @authResponse = Util::Params::Functions.authenticate(email, password)
  @response = @client.send(:post, "/events")
  @response.set_headers('Auth-Token' => @authResponse['authToken'])
  if @image
    str_params << ",eventImage=#{@image}"
  end

  @response.set_params(Util::Params.parse(str_params))
  @event =  @response.json

end

Given /^I have an image named "([^"]*)"$/ do |image_name|
  @image = Base64.encode64(File.read(File.join(File.dirname(__FILE__), '..', '..','..', 'specs','fixtures', image_name)))
  puts "populated image"
end


When /^I am retrieving the created event$/ do
  @response = @client.send(:get, "/events/#{@event["id"]}")
  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end
end


Then /^Response should not contain any private Events$/ do
  events = @response.json
  events.each do |event|
    event["permission"].should_not == "private"
  end
end

Then /^Retrieved Event id should be equal to the created Events id$/ do
  event = @response.json
  event["id"].should == @event["id"]
end




When /^I change the attribute "([^"]*)"$/ do |str_params|

  @response = @client.send(:put, "/events/#{@event["id"]}")
  @response.set_headers('Auth-Token' => @authResponse['authToken'])
  @response.set_params(Util::Params.parse(str_params))
  @event = @response.json
end


Then /^Event "([^"]*)" should be equal to "([^"]*)"$/ do |attr, value|
  @event[attr].should == value
end


When /^I'm posting with image "([^"]*)"$/ do |str_params|

    str_params << ",eventImage=#{@image}"
  @response.set_params(Util::Params.parse(str_params))
end
