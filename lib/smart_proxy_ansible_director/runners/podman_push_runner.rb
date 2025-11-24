# frozen_string_literal: true

require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'

module Proxy
  module AnsibleDirector
    module Runners
      class PodmanPushRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        def initialize(podman_push_input, suspended_action: nil)
          super suspended_action: suspended_action
          puts podman_push_input
          @ee_id = podman_push_input[:ee_id]
        end

        def start
          # TODO: Parametrize

          image_name = "ansibleng/#{@ee_id}:latest"
          registry = 'centos9-katello-devel-stable.example.com:4321'

          cmd = <<~CMD
            podman push --tls-verify=false #{image_name} #{registry}/#{image_name}
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
