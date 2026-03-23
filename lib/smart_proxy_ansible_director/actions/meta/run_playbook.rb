# frozen_string_literal: true

require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'
require 'smart_proxy_dynflow/callback'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta
        class RunPlaybook < ::Proxy::Dynflow::Action::Runner
          def plan(args)
            execution_environment = args['execution_environment']

            ee_id = execution_environment['id']
            ee_registry_url = execution_environment['registry_url']
            ee_ansible_core_version = execution_environment['ansible_core_version']


            inventory = args['inventory']
            playbook = args['playbook']
            variables = args['variables']
            content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              args['content']
            )

            sequence do
              plan_action ::Proxy::AnsibleDirector::Actions::BuildExecutionEnvironment, {
                ee_id: ee_id,
                ee_base_image_url: ee_registry_url,
                ee_built_image_tag: @caller_execution_plan_id,
                ee_ansible_core_version: ee_ansible_core_version,
                ee_formatted_content: content,
                is_base_image: false
              }
              run_ansible_action = plan_action ::Proxy::AnsibleDirector::Actions::RunAnsibleNavigator, {
                inventory: inventory,
                playbook: playbook,
                variables: variables,
                execution_environment: ee_registry_url.sub!("latest", @caller_execution_plan_id)
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
