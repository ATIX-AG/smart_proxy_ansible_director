# frozen_string_literal: true

require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta
        class BuildPushEe < ::Proxy::Dynflow::Action::Runner
          #           "action_input": {
          #             "execution_environment": {
          #               "id": 1,
          #               "content": {
          #                 "base_image": "registry.fedoraproject.org/fedora:42",
          #                 "ansible_core_version": "",
          #                 "content_units": [
          #                   {
          #                     "type": "collection",
          #                     "identifier": "nextcloud.admin",
          #                     "version": "2.0.0",
          #                     "source": "https://galaxy.ansible.com"
          #                   }
          #                 ]
          #               }
          #             }
          #           }
          def plan(args)
            execution_environment = args['execution_environment']
            ee_id = execution_environment['id']
            execution_environment_content = execution_environment['content']
            ee_base_image = execution_environment_content['base_image']
            ee_base_image_tag = 'latest'
            ee_ansible_core_version = execution_environment_content['ansible_core_version']
            ee_formatted_content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              execution_environment_content['content_units']
            )

            sequence do
              plan_action ::Proxy::AnsibleDirector::Actions::BuildExecutionEnvironment, {
                ee_id: ee_id,
                ee_base_image: ee_base_image,
                ee_base_image_tag: ee_base_image_tag,
                ee_ansible_core_version: ee_ansible_core_version,
                ee_formatted_content: ee_formatted_content,
                is_base_image: true
              }
              plan_action ::Proxy::AnsibleDirector::Actions::PushExecutionEnvironment, {
                ee_id: ee_id
              }
            end
          end
        end
      end
    end
  end
end
