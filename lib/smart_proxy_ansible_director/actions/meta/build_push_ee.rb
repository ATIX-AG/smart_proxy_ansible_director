require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta

        class BuildPushEe < ::Proxy::Dynflow::Action::Runner

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
            ee_id = _execution_environment["id"]
            _execution_environment_content = _execution_environment["content"]
            ee_base_image = _execution_environment_content["base_image"]
            ee_base_image_tag = _execution_environment_content["latest"]
            ee_ansible_core_version = _execution_environment_content["ansible_core_version"]
            ee_formatted_content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              _execution_environment_content["content_units"]
            )


            sequence do
              plan_action ::Proxy::AnsibleDirector::Actions::BuildExecutionEnvironment, {
                ee_id: ee_id,
                ee_base_image: ee_base_image,
                ee_base_image_tag: ee_base_image_tag,
                ee_ansible_core_version: ee_ansible_core_version,
                ee_formatted_content: ee_formatted_content
              }
              plan_action ::Proxy::AnsibleDirector::Actions::PushExecutionEnvironment, {
                ee_id: ee_id,
              }
              # TODO: Callback to foreman with metadata
            end
          end
        end
      end
    end
  end
end
