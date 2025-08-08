module Proxy

  module Pulsible

    module Runners
      require 'smart_proxy_pulsible/runners/ansible_builder_runner'
      require 'smart_proxy_pulsible/runners/ansible_navigator_runner'
      require 'smart_proxy_pulsible/runners/podman_push_runner'
    end
  end
end