require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'

module Proxy
  module AnsibleDirector
    module Runners
      class AnsibleNavigatorRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        def initialize(ansible_input, suspended_action: nil)
          super suspended_action: suspended_action
          @inventory = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_inventory(ansible_input[:inventory])
          @playbook = ::Proxy::AnsibleDirector::Helpers::AnsibleNavigatorHelpers.reserialize_playbook(ansible_input[:playbook])
          @execution_environment = ansible_input[:execution_environment]
        end

        def start
          # TODO: Find a way to request the auth token programmatically
          cmd = <<~CMD
            AUTHFILE=$(mktemp /dev/shm/auth.XXXXXX.json)
                
            cat > "$AUTHFILE" <<'EOF'
            {
              "auths": {
                "my.custom.registry.com": {
                  "auth": "YWRtaW46Y2hhbmdlbWU="
                }
              }
            }
            EOF

            TMPDIR=$(mktemp -d /tmp/ansible-run_XXXXXX)
            echo $TMPDIR
            cd $TMPDIR       

            cat > "playbook.yaml" <<'EOF'
            #{@playbook}
            EOF

            cat > "inventory.yaml" <<'EOF'
            #{@inventory}
            EOF

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
      end
    end
  end
end