# frozen_string_literal: true

module Proxy
  module AnsibleDirector
    module Actions
      class BuildExecutionEnvironment < ::Proxy::Dynflow::Action::Runner
        # {
        #   ee_id: int,
        #   ee_name: '',
        #   ee_base_image: '',
        #   ee_formatted_content: <yaml string>
        # }
        def plan(build_ee_input)
          plan_self build_ee_input: build_ee_input
        end

        def initiate_runner
          ::Proxy::AnsibleDirector::Runners::AnsibleBuilderRunner.new(input[:build_ee_input])
        end
      end
    end
  end
end
