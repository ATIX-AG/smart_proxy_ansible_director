require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'
require 'smart_proxy_dynflow/callback'

module Proxy
  module AnsibleDirector
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
            variables = args["variables"]
            content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              args["content"]
            )

            puts _execution_environment

            sequence do
              build_ee_action = plan_action ::Proxy::AnsibleDirector::Actions::BuildExecutionEnvironment, {
                ee_id: _execution_environment.split('/')[-1],
                ee_base_image: _execution_environment,
                ee_base_image_tag: @caller_execution_plan_id,
                ee_ansible_core_version: "2.19.0", # TODO: Get from EE
                ee_formatted_content: content
              }
              run_ansible_action = plan_action ::Proxy::AnsibleDirector::Actions::RunAnsibleNavigator, {
                inventory: _inventory,
                playbook: _playbook,
                variables: variables,
                execution_environment: "#{_execution_environment.split('/')[-1]}:#{@caller_execution_plan_id}",
              }
              plan_action ::Proxy::Dynflow::Callback::Action,
                          args[:callback],
                          run_ansible_action.output
            end
          end
        end
      end
    end
  end
end
