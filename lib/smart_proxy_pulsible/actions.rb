module Proxy

  module Pulsible

    module Actions
      require 'smart_proxy_pulsible/actions/build_execution_environment'
      require 'smart_proxy_pulsible/actions/run_ansible_navigator'
      require 'smart_proxy_pulsible/actions/meta/build_push_ee'
      require 'smart_proxy_pulsible/actions/meta/run_playbook'
    end
  end
end