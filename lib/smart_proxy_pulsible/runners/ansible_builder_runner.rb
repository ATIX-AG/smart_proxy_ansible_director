require 'smart_proxy_dynflow/runner/process_manager_command'

module Proxy
  module Pulsible
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
          super suspended_action: suspended_action
        end

        def start

          ee_definition = {
            "version" => 3,
            "images" => {
              "base_image" => {
                "name" => @ee_base_image
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
              "galaxy" => @ee_formatted_content.to_hash
            }
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