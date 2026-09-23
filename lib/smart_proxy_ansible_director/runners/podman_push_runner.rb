# frozen_string_literal: true

require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'

module Proxy
  module AnsibleDirector
    module Runners
      class PodmanPushRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        attr_reader :continuous_output, :exit_status

        def initialize(podman_push_input, suspended_action: nil)
          super suspended_action: suspended_action
          @push_url = podman_push_input[:push_url]
        end

        def start
          cert_dir = File.join(
            Proxy::AnsibleDirector::Plugin.settings[:workdir_root],
            'certs'
          )
          cmd = <<~CMD
            podman push --cert-dir #{cert_dir} #{@push_url}
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
      end
    end
  end
end
