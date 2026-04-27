# frozen_string_literal: true

require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'
require_relative '../../runners/meta_runner'
require 'smart_proxy_dynflow/callback'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta
        class RunPlaybook < ::Proxy::Dynflow::Action::Runner
          def initiate_runner
            execution_environment = input['execution_environment']

            ee_id = execution_environment['id']
            ee_registry_url = execution_environment['registry_url']
            ee_ansible_core_version = execution_environment['ansible_core_version']


            inventory = input['inventory']
            playbook = input['playbook']
            variables = input['variables']
            content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              input['content']
            )

            ::Proxy::AnsibleDirector::Runners::MetaRunner.new(
              {
                build_ee_input: {
                  ee_id: ee_id,
                  ee_base_image_url: ee_registry_url,
                  ee_built_image_tag: @caller_execution_plan_id,
                  ee_ansible_core_version: ee_ansible_core_version,
                  ee_formatted_content: content,
                  is_base_image: false
                },
                run_ansible_input: {
                  inventory: inventory,
                  playbook: playbook,
                  variables: variables,
                  execution_environment: ee_registry_url.sub("latest",
                                                             @caller_execution_plan_id)
                }
              }
            )
          end
        end
      end
    end
  end
end
