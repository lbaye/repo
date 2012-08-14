When /^Response should have at least "([^"]*)" item$/ do |number|
  @response.json.size.should be >= number.to_i
end

When /^I've created a message with "([^"]*)" and recipients as "([^"]*)"$/ do |str_params, str_recipients|
  recipients = str_recipients.split(',').map do |ref|
    case ref
      when 'me'
        @authResponse['id']

      else
        Util::Params::Functions.get_user_by_email(@authResponse, ref)['id']
    end
  end

  @messages ||= []

  @messages << Util::Params::Functions.create_message(
      @authResponse,
      Util::Params::parse(str_params).merge('recipients[]' => recipients)
  )
end

When /^I'm creating message with thread_id$/ do
  @response = Util::Params::Functions.create_message_context(@authResponse,
      subject: 'Hi', content: 'Hello', 'recipients[]' => @authResponse['id'],
      thread: @messages.last['id']
  )
end