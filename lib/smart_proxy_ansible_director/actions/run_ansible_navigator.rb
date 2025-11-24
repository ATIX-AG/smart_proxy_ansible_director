# frozen_string_literal: true

module Proxy
  module AnsibleDirector
    module Actions
      class RunAnsibleNavigator < ::Proxy::Dynflow::Action::Runner
        def plan(args)
          plan_self args: args
        end

        def initiate_runner
          ::Proxy::AnsibleDirector::Runners::AnsibleNavigatorRunner.new(input[:args])
        end
      end
    end
  end
end
