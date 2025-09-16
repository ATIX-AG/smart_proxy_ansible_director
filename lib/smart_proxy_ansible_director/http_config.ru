require 'smart_proxy_ansible_director/api'

map "/ansible" do
  run Proxy::AnsibleDirector::Api
end
