# frozen_string_literal: true

require_relative '../build_execution_environment'
require_relative '../push_execution_environment'
require_relative '../../helpers/execution_environment_helpers'
require_relative '../../runners/ansible_builder_runner'
require_relative '../../runners/ansible_navigator_runner'
require_relative '../../runners/meta_runner'

module Proxy
  module AnsibleDirector
    module Actions
      module Meta
        class RunPlaybook < ::Proxy::Dynflow::Action::Runner
          RUNNER_PHASES = [
            { id: :build_ee, title: 'Building execution environment',
              runner_class: ::Proxy::AnsibleDirector::Runners::AnsibleBuilderRunner,
              runner_input_key: :build_ee_input },
            { id: :run_ansible, title: 'Running Ansible',
              runner_class: ::Proxy::AnsibleDirector::Runners::AnsibleNavigatorRunner,
              runner_input_key: :run_ansible_input }
          ].freeze

          def initiate_runner
            execution_environment = input['execution_environment']

            ee_pull_url = execution_environment['pull_url']
            ee_ansible_core_version = execution_environment['ansible_core_version']

            ee_run_image_tag = ee_pull_url.sub("latest",
                                               @caller_execution_plan_id)

            inventory = input['inventory']
            playbook = input['playbook']
            variable_files = input['variable_files'].to_hash
            content = ::Proxy::AnsibleDirector::Helpers::ExecutionEnvironmentHelpers.format_content(
              input['content']
            )

            ::Proxy::AnsibleDirector::Runners::MetaRunner.new(
              RUNNER_PHASES,
              {
                build_ee_input: {
                  ee_base_image_url: ee_pull_url,
                  ee_built_image_tag: ee_run_image_tag,
                  ee_ansible_core_version: ee_ansible_core_version,
                  ee_formatted_content: content,
                  is_base_image: false
                },
                run_ansible_input: {
                  inventory: inventory,
                  playbook: playbook,
                  variable_files: variable_files,
                  execution_environment: ee_run_image_tag
                }
              }
            )
          end
        end
      end
    end
  end
end
