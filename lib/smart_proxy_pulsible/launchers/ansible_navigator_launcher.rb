# frozen_string_literal: true

require 'smart_proxy_dynflow/task_launcher'

module Proxy
  module Pulsible
    module Launchers
      class AnsibleNavigatorLauncher < ::Proxy::Dynflow::TaskLauncher::Batch
      end
    end
  end
end

