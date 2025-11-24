# frozen_string_literal: true

require 'smart_proxy_dynflow/task_launcher'

module Proxy
  module AnsibleDirector
    module Launchers
      class MetaLauncher < ::Proxy::Dynflow::TaskLauncher::Batch
      end
    end
  end
end
