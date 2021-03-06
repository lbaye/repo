module Util
  module Params
    module Functions
      def rand
        (Time.now.to_i * Random.rand).to_s.gsub(/\./, '')
      end

      def create_user
        client   = ClientUtil.create_client
        response = client.send(:post, '/auth/registration')
        response.set_params({ email: "user#{rand}@test.com", password: 'abcdef', firstName: "ab", lastName: "cd", avatar: "www.google.com/xxyz" })
        JSON.load(response.response.body)
      end

      def authenticate(email, password)
        client   = ClientUtil.create_client
        response = client.send(:post, '/auth/login')
        response.set_params({ email: email, password: password })
        JSON.load(response.response.body)
      end

      def create_message(auth_response, params)
        JSON.load(create_message_context(auth_response, params).body)
      end

      def create_message_context(auth_response, params)
        client   = ClientUtil.create_client
        response = client.send(:post, '/messages')
        response.set_headers('Auth-Token' => auth_response['authToken'])
        response.set_params(params)
        response
      end

      def get_user_by_email(auth_response, email)
        client   = ClientUtil.create_client
        response = client.send(:get, "/users/email/#{email}")
        response.set_headers('Auth-Token' => auth_response['authToken'])
        JSON.load(response.body)
      end

      def update_status(auth_response, id, status)
        client = ClientUtil.create_client
        response = client.send(:post, "/messages/#{id}/status/#{status}")
        response.set_headers('Auth-Token' => auth_response['authToken'])
        JSON.load(response.body)
      end

      def create_event(auth_response, params)
        client = ClientUtil.create_client
        response = client.send(:post, '/messages')
      end

      def rand_email
        "user#{rand}@email.com"
      end

      def rand_string(arg = '')
        "#{arg}-#{rand}"
      end

      def since_two_day
        (Time.now - 2.days).to_i.to_s
      end

      module_function :rand, :authenticate, :rand_email,
                      :create_message, :create_user, :create_message_context,
                      :get_user_by_email, :update_status, :since_two_day, :rand_string
    end
  end
end