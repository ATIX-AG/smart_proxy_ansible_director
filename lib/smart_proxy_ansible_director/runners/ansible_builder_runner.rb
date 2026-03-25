# frozen_string_literal: true

require 'smart_proxy_dynflow/runner/process_manager_command'

module Proxy
  module AnsibleDirector
    module Runners
      class AnsibleBuilderRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        # ansible_builder_input
        # {
        #   ee_id: ee_id,
        #   ee_base_image: ee_base_image,
        #   ee_ansible_core_version: ee_ansible_core_version,
        #   ee_formatted_content: ee_formatted_content
        # }
        def initialize(ansible_builder_input, suspended_action: nil)
          # ID of the execution environment definition; supplied by Foreman
          @ee_id = ansible_builder_input[:ee_id]
          # TAGGED registry URL of the base image; supplied by Foreman
          @ee_base_image_url = ansible_builder_input[:ee_base_image_url]
          # Tag used at the end of building for this image
          @ee_built_image_tag = ansible_builder_input[:ee_built_image_tag]
          @ee_ansible_core_version = ansible_builder_input[:ee_ansible_core_version]
          @ee_formatted_content = ansible_builder_input[:ee_formatted_content]
          @is_base_image = ansible_builder_input[:is_base_image]

          workdir_base = Proxy::AnsibleDirector::Plugin.settings[:execution_env_build_dir]
          @runner_workdir = Dir.mktmpdir('execution_env', workdir_base)
          super suspended_action: suspended_action
        end

        def start
          ee_content = @ee_formatted_content.to_hash

          if @is_base_image
            ee_content.merge!(
              { 'collections' => [
                {
                  'name' => 'theforeman.foreman',
                  'version' => '5.6.0',
                  'source' => 'https://galaxy.ansible.com'
                }
              ] }
            )
          end

          ee_definition = {
            'version' => 3,
            'images' => {
              'base_image' => {
                'name' => @ee_base_image_url
              }
            },
            'dependencies' => {
              'python_interpreter' => {
                'package_system' => 'python3'
              },
              'ansible_core' => {
                'package_pip' => "ansible-core==#{@ee_ansible_core_version}"
              },
              'ansible_runner' => {
                'package_pip' => 'ansible-runner'
              },
              'system' => ['openssh-clients'],
              'galaxy' => ee_content
            },
            'additional_build_steps' => (
                unless @is_base_image
                  {
                    'prepend_base' => [
                      'ENV ANSIBLE_CALLBACK_WHITELIST=theforeman.foreman.foreman',
                      'ENV ANSIBLE_CALLBACKS_ENABLED=theforeman.foreman.foreman',
                      "ENV FOREMAN_URL=#{Proxy::SETTINGS.foreman_url}",
                      'ENV FOREMAN_SSL_CERT=/run/secrets/foreman_ssl_cert',
                      'ENV FOREMAN_SSL_KEY=/run/secrets/foreman_ssl_key',
                      'ENV FOREMAN_SSL_VERIFY=/run/secrets/foreman_ssl_verify'

                    ]
                  }
                end
              )
          }.compact

          build_args = {
            ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '-c'
          }

          build_args_str = ''

          build_args.each do |k, v|
            build_args_str += "--build-arg #{k}=\"#{v}\" "
          end

          # COMPAT 3.16 - 2
          # --extra-build-cli-args is not supported in ansible-builder 3.0.0
          # Verbosity is chosen by passing -v {0, 1, 2, 3}

          cmd = <<~CMD
            echo "Running in #{@runner_workdir}"

            cat <<EOF > "#{@runner_workdir}/execution-environment.yml"
            #{YAML.dump(ee_definition, indentation: 2)}
            EOF
            ansible-builder build --tag ansible_director/#{@ee_id}:#{@ee_built_image_tag} -v 3 --file #{@runner_workdir}/execution-environment.yml #{build_args_str} --context #{@runner_workdir}
          CMD

          initialize_command('bash', '-c', cmd)
        end

        def refresh
          @process_manager.process(timeout: 0.1) unless @process_manager.done?
          puts @continuous_output.raw_outputs
          publish_exit_status(@process_manager.status) if @process_manager.done?
        end

        def close
          remove_workdirs = Proxy::AnsibleDirector::Plugin.settings[:remove_workdirs]
          FileUtils.rm_rf @runner_workdir if remove_workdirs
        end

        def publish_data(message, type = 'debug')
            @continuous_output.add_output(message.force_encoding('UTF-8'), type)
        end
      end
    end
  end
end
