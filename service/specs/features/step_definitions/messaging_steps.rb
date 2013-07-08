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
  @response = Util::Params::Functions.
      create_message_context(
      @authResponse, subject: 'Hi', content: 'Hello',
      'recipients[]'          => @authResponse['id'],
      thread:                 @messages.last['id']
  )
end

When /^I've created several messages$/ do
  @new_messages = 5.times.map {
    Util::Params::Functions.create_message_context(
        @authResponse, subject: 'Hi', content: 'Hello',
        'recipients[]'          => @authResponse['id']).json
  }
end

When /^I've sent few update requests through updating status$/ do
  message_1 = @new_messages[1]
  Util::Params::Functions.update_status(@authResponse, message_1['id'], 'read')

  @updated_messages = [
      message_1
  ]
end

When /^Messages are ordered by updating date$/ do
  @response.json.map { |o| o['id'] }.
      include?(@updated_messages.first['id']).should be
end

When /^Two recipients are added in the list$/ do
  recipients = @response.json['recipients']
  recipients.size.should == 2
end

When /^I've added several message replies$/ do
  Util::Params::Functions.create_message_context(
      @authResponse, subject: 'Reply 1', content: 'Content '
  )
end