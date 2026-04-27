# frozen_string_literal: true

require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'
require 'yaml'

module Proxy
  module AnsibleDirector
    module Runners
      class AnsibleNavigatorRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        attr_reader :continuous_output, :exit_status

        def initialize(ansible_input, suspended_action: nil)
          super suspended_action: suspended_action
          @inventory = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_inventory(ansible_input[:inventory])
          if ansible_input[:mode] == 'literal'
            @playbook = ansible_input[:playbook]
            @variables = {}
          else
            @playbook = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_playbook(ansible_input[:playbook])
            @variables = ansible_input[:variables]
          end
          @execution_environment = ansible_input[:execution_environment]

          workdir_base = Proxy::AnsibleDirector::Plugin.settings[:ansible_navigator_run_dir]
          @runner_workdir = Dir.mktmpdir('navigator', workdir_base)
        end

        def start
          # TODO: Find a way to request the auth token programmatically
          cmd = <<~CMD
            echo "Running in #{@runner_workdir}"

            cat > "#{@runner_workdir}/playbook.yaml" <<'EOF'
            #{@playbook}
            EOF

            cat > "#{@runner_workdir}/inventory.yaml" <<'EOF'
            #{@inventory}
            EOF

            mkdir #{@runner_workdir}/vars

            #{
              @variables.map do |role_name, variables|
                %(cat > "#{@runner_workdir}/vars/#{role_name}_vars.yaml" <<'EOF'\n#{format_variables role_name, variables}EOF)
              end.join("\n\n")
            }

            cat > "#{@runner_workdir}/ansible-navigator.yml" <<'EOF'
            ---
            ansible-navigator:
              ansible:
                inventory:
                  entries:
                    - #{@runner_workdir}/inventory.yaml
                playbook:
                  path: #{@runner_workdir}/playbook.yaml
              ansible-runner:
                artifact-dir: #{@runner_workdir}
              execution-environment:
                image: #{@execution_environment}
                pull:
                  arguments:
                    - "--tls-verify=false"
                    - "--authfile=$AUTHFILE"
                  policy: missing
                volume-mounts:
                  - src: #{File.join(Dir.pwd, Proxy::SETTINGS.foreman_ssl_cert)}
                    dest: /run/secrets/foreman_ssl_cert
                  - src: #{File.join(Dir.pwd, Proxy::SETTINGS.foreman_ssl_key)}
                    dest: /run/secrets/foreman_ssl_key
                  - src: #{File.join(Dir.pwd, Proxy::SETTINGS.foreman_ssl_ca)}
                    dest: /run/secrets/foreman_ssl_verify
                  - src: /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy
                    dest: /runner/.ssh/id_rsa_foreman_proxy
              logging:
                level: debug
                file: #{@runner_workdir}/ansible-navigator.log
              mode: stdout
            EOF

            ANSIBLE_NAVIGATOR_CONFIG=#{@runner_workdir}/ansible-navigator.yml ansible-navigator run --mode stdout
          CMD
          initialize_command('bash', '-c', cmd)
        end

        def refresh
          @process_manager.process(timeout: 0.1) unless @process_manager.done?
          puts @continuous_output.humanize
          publish_exit_status(@process_manager.status) if @process_manager.done?
        end

        def publish_data(message, type = 'debug')
            @continuous_output.add_output(message.force_encoding('UTF-8'), type)
        end

        def close
          remove_workdirs = Proxy::AnsibleDirector::Plugin.settings[:remove_workdirs]
          FileUtils.rm_rf @runner_workdir if remove_workdirs
        end

        private

        def format_variables(_role_name, variables)
          formatted = {}
          variables.each do |k, v|
            formatted_v = begin
              YAML.safe_load v
            rescue Exception
              v
            end
            formatted[k] = formatted_v
          end

          formatted.to_h.to_yaml
        end
      end
    end
  end
end
