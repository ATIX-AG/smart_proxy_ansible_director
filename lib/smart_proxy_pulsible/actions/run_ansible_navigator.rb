

module Proxy
  module Pulsible
    module Actions
      class RunAnsibleNavigator < ::Proxy::Dynflow::Action::Runner

        def plan(args)
          plan_self args: args
        end

        def initiate_runner
          ::Proxy::Pulsible::Runners::AnsibleNavigatorRunner.new(input[:args])
        end
      end
    end
  end
end