# frozen_string_literal: true

require 'smart_proxy_ansible_director/api'

map '/ansible-director' do
  run Proxy::AnsibleDirector::Api
end
