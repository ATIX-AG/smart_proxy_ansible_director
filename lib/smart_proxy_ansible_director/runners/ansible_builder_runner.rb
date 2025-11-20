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
          @ee_id = ansible_builder_input[:ee_id]
          @ee_base_image = ansible_builder_input[:ee_base_image]
          @ee_base_image_tag = ansible_builder_input[:ee_base_image_tag]
          @ee_ansible_core_version = ansible_builder_input[:ee_ansible_core_version]
          @ee_formatted_content = ansible_builder_input[:ee_formatted_content]
          @is_base_image = ansible_builder_input[:is_base_image]
          super suspended_action: suspended_action
        end

        def start

          ee_content = @ee_formatted_content.to_hash

          if @is_base_image
              ee_content.merge!(
                  { "collections" => [
                      {
                        "name" => "theforeman.foreman",
                        "version" => "5.6.0",
                        "source" => "https://galaxy.ansible.com"
                      }
                    ]
                  }
                )
          end

          ee_definition = {
            "version" => 3,
            "images" => {
              "base_image" => {
                "name" => "localhost/ansibleng/1:latest"
              }
            },
            "dependencies" => {
              "python_interpreter" => {
                "package_system" => 'python3'
              },
              "ansible_core" => {
                "package_pip" => "ansible-core==#{@ee_ansible_core_version}"
              },
              "ansible_runner" => {
                "package_pip" => 'ansible-runner'
              },
              "system" => ["openssh-clients"],
              "galaxy" => ee_content
            },
            "additional_build_steps" => (
                {
                    "prepend_base" => [
                        "ENV ANSIBLE_CALLBACK_WHITELIST=theforeman.foreman.foreman",
                        "ENV ANSIBLE_CALLBACKS_ENABLED=theforeman.foreman.foreman",
                        "ENV FOREMAN_URL=#{Proxy::SETTINGS.foreman_url.to_s}",
                        "ENV FOREMAN_SSL_CERT=/run/secrets/foreman_ssl_cert",
                        "ENV FOREMAN_SSL_KEY=/run/secrets/foreman_ssl_key",
                        "ENV FOREMAN_SSL_VERIFY=/run/secrets/foreman_ssl_verify",

                ]
                } unless @is_base_image
            )
          }.compact

          build_args = {
            ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '-c',
          }

          build_args_str = ''

          build_args.each do |k, v|
            build_args_str += "--build-arg #{k}=\"#{v}\" "
          end

          cmd = <<~CMD
              TMPDIR=$(mktemp -d /tmp/execution-environment_ctx_XXXXXX)
              echo $TMPDIR
              cd $TMPDIR       

              cat <<EOF > "execution-environment.yml"
              #{YAML.dump(ee_definition, indentation: 2)}
              EOF
              ansible-builder build --tag ansibleng/#{@ee_id}:#{@ee_base_image_tag} -vvv --extra-build-cli-args='--tls-verify=false' --file execution-environment.yml #{build_args_str}
          CMD

          initialize_command('bash', '-c', cmd)
        end

        def refresh
          @process_manager.process(timeout: 0.1) unless @process_manager.done?
          puts @continuous_output.raw_outputs
          publish_exit_status(@process_manager.status) if @process_manager.done?
        end
      end
    end
  end
end