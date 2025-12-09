require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'
require 'yaml'

module Proxy
  module AnsibleDirector
    module Runners
      class AnsibleNavigatorRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        def initialize(ansible_input, suspended_action: nil)
          super suspended_action: suspended_action
          @inventory = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_inventory(ansible_input[:inventory])
          if ansible_input[:mode] == "literal"
              @playbook = ansible_input[:playbook]
              @variables = {}
          else
              @playbook = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_playbook(ansible_input[:playbook])
              @variables = ansible_input[:variables]
          end
          @execution_environment = ansible_input[:execution_environment]
        end

        def start
          # TODO: Find a way to request the auth token programmatically
          cmd = <<~CMD

              TMPDIR=$(mktemp -d /tmp/ansible-run_XXXXXX)
              echo $TMPDIR
              cd $TMPDIR       

              cat > "playbook.yaml" <<'EOF'
              #{@playbook}
              EOF

              cat > "inventory.yaml" <<'EOF'
              #{@inventory}
              EOF

              mkdir vars

              #{
                @variables.map do |role_name, variables|
                    %Q(cat > "vars/#{role_name}_vars.yaml" <<'EOF'\n#{format_variables role_name, variables}EOF)
                end.join("\n\n")
              }

              cat > "ansible-navigator.yaml" <<'EOF'
              ---
              ansible-navigator:
                ansible:
                  inventory:
                    entries:
                      - ./inventory.yaml
                  playbook:
                    path: ./playbook.yaml
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
                      options: Z,ro
                    - src: #{File.join(Dir.pwd, Proxy::SETTINGS.foreman_ssl_key)}
                      dest: /run/secrets/foreman_ssl_key
                      options: Z,ro
                    - src: #{File.join(Dir.pwd, Proxy::SETTINGS.foreman_ssl_ca)}
                      dest: /run/secrets/foreman_ssl_verify
                      options: Z,ro
                logging:
                  level: debug
                mode: stdout
              EOF

              ansible-navigator run --mode stdout
          CMD
          initialize_command('bash', '-c', cmd)
        end

        def refresh
          @process_manager.process(timeout: 0.1) unless @process_manager.done?
          puts @continuous_output.humanize
          publish_exit_status(@process_manager.status) if @process_manager.done?
        end

        private

        def format_variables(role_name, variables)
            formatted = {}
            variables.each do |k, v|
                formatted_v = begin
                    YAML.safe_load v
                rescue Exception => e
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