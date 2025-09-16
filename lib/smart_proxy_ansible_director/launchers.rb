module Proxy

  module AnsibleDirector

    module Launchers
      require 'smart_proxy_ansible_director/launchers/ansible_builder_launcher'
      require 'smart_proxy_ansible_director/launchers/ansible_navigator_launcher'
      require 'smart_proxy_ansible_director/launchers/meta_launcher'
    end
  end
end