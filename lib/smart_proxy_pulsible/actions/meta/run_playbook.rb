require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'

module Proxy
  module Pulsible
    module Actions
      module Meta

        class RunPlaybook < ::Proxy::Dynflow::Action::Runner

=begin
          "action_input": {
            "execution_environment": {
              "id": 1,
              "content": {
                "base_image": "registry.fedoraproject.org/fedora:42",
                "ansible_core_version": "",
                "content_units": [
                  {
                    "type": "collection",
                    "identifier": "nextcloud.admin",
                    "version": "2.0.0",
                    "source": "https://galaxy.ansible.com"
                  }
                ]
              }
            }
          }
=end
          def plan(args)

            _execution_environment = args["execution_environment"]
            _inventory = args["inventory"]
            _playbook = args["playbook"]
            content = ::Proxy::Pulsible::Helpers::ExecutionEnvironmentHelpers.format_content(
              args["content"]
            )

            sequence do
              plan_action ::Proxy::Pulsible::Actions::BuildExecutionEnvironment,  {
                ee_id: @caller_execution_plan_id,
                ee_base_image: _execution_environment,
                ee_base_image_tag: @caller_execution_plan_id,
                ee_ansible_core_version: "2.19.0", # TODO: Get from EE
                ee_formatted_content: content
              }
              plan_action ::Proxy::Pulsible::Actions::RunAnsibleNavigator, {
                inventory: _inventory,
                playbook: _playbook,
                execution_environment: "#{@caller_execution_plan_id}:#{@caller_execution_plan_id}",
              }
              # TODO: Callback to foreman with metadata
            end
          end
        end
      end
    end
  end
end
