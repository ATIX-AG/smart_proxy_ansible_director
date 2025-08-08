# frozen_string_literal: true

require 'smart_proxy_dynflow/task_launcher'

module Proxy
  module Pulsible
    module Launchers
      class AnsibleBuilderLauncher < ::Proxy::Dynflow::TaskLauncher::Single
      end
    end
  end
end

