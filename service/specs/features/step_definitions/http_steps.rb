When /^I'm sending http "(.*?)" request to "(.*?)"$/ do |http_method, uri|
  @response = @client.send(http_method.downcase.to_sym, uri)

  if @authResponse
    @response.set_headers('Auth-Token' => @authResponse['authToken'])
  end

  if uri.match(/\{msg_last_id\}/)
    uri.gsub!(/\{msg_last_id\}/, (@messages || []).last['id'])
    @response.set_uri("#{@client.service_uri}#{uri}")
  end

  if (result = uri.match(/eval\((.*?)\)/))
    uri.gsub!(/(eval\((.*?)\))/, eval("#{result[1]}"))
    @response.set_uri("#{@client.service_uri}#{uri}")
  end
end

When /^I'm posting "(.*?)"$/ do |str_params|
  @response.set_params(Util::Params.parse(str_params))
end



Then /^I should see http "(.*?)" status$/ do |code|
  #p @response.body
  @response.code.should == code
end

Then /^Response is valid "(.*?)" formatted$/ do |type|
  @response.response.content_type.should == type
end

Then /^Response should match "(.*?)"$/ do |content|
  @response.body.should match /#{content}/
end

When /^Response should have "([^"]*)" attribute$/ do |field|
  json = @response.json

  if json.is_a?(Array)
    json.first[field].should be
  else
    json[field].should be
  end
end