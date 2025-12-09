require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'

module Proxy
    module AnsibleDirector
        module Runners
            class PodmanPullRunner < ::Proxy::Dynflow::Runner::Base
                include ::Proxy::Dynflow::Runner::ProcessManagerCommand

                def initialize(podman_pull_input, suspended_action: nil)
                    super suspended_action: suspended_action
                    @ee_registry_url = podman_pull_input[:ee_registry_url]
                end

                def start
                    cmd = <<~CMD
                        podman pull --tls-verify=false #{@ee_registry_url}
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