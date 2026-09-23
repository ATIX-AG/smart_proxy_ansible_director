# frozen_string_literal: true

require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'
require_relative '../../runners/ansible_builder_runner'
require_relative '../../runners/podman_push_runner'
require_relative '../../runners/meta_runner'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta
        class BuildPushEe < ::Proxy::Dynflow::Action::Runner
          RUNNER_PHASES = [
            { id: :build_ee, title: 'Building execution environment',
              runner_class: ::Proxy::AnsibleDirector::Runners::AnsibleBuilderRunner,
              runner_input_key: :build_ee_input },
            { id: :push_ee, title: 'Pushing execution environment',
              runner_class: ::Proxy::AnsibleDirector::Runners::PodmanPushRunner,
              runner_input_key: :push_ee_input }
          ].freeze

          def initiate_runner
            execution_environment_definition = input['execution_environment']
            push_url = input['push_url']

            ee_id = execution_environment_definition['id']
            execution_environment_content = execution_environment_definition['content']

            ee_base_image = execution_environment_content['base_image']
            ee_base_image_tag = push_url
            ee_ansible_core_version = execution_environment_content['ansible_core_version']
            ee_formatted_content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              execution_environment_content['content_units']
            )

            ::Proxy::AnsibleDirector::Runners::MetaRunner.new(
              RUNNER_PHASES,
              {
                build_ee_input: {
                  ee_id: ee_id,
                  ee_base_image_url: ee_base_image,
                  ee_built_image_tag: ee_base_image_tag,
                  ee_ansible_core_version: ee_ansible_core_version,
                  ee_formatted_content: ee_formatted_content,
                  is_base_image: true
                },
                push_ee_input: {
                  push_url: push_url
                }
              }
            )
          end
        end
      end
    end
  end
end
