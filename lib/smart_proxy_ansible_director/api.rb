module Proxy
  module AnsibleDirector
    class Api < ::Sinatra::Base
      helpers ::Proxy::Helpers

      # Require authentication
      authorize_with_trusted_hosts
      authorize_with_ssl_client

      get '/' do
        content = 'Hello World!'

        content_type :json
        content.to_json
      end
    end
  end
end
