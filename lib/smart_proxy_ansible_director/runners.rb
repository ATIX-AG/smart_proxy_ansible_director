module Proxy

  module AnsibleDirector

    module Runners
      require 'smart_proxy_ansible_director/runners/ansible_builder_runner'
      require 'smart_proxy_ansible_director/runners/ansible_navigator_runner'
      require 'smart_proxy_ansible_director/runners/podman_push_runner'
      require 'smart_proxy_ansible_director/runners/podman_pull_runner'
      require 'smart_proxy_ansible_director/runners/ansible_script_runner'
    end
  end
end