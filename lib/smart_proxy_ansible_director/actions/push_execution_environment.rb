# frozen_string_literal: true

module Proxy
  module AnsibleDirector
    module Actions
      class PushExecutionEnvironment < ::Proxy::Dynflow::Action::Runner
        def plan(push_ee_input)
          plan_self push_ee_input: push_ee_input
        end

        def initiate_runner
          ::Proxy::AnsibleDirector::Runners::PodmanPushRunner.new(input[:push_ee_input])
        end
      end
    end
  end
end
