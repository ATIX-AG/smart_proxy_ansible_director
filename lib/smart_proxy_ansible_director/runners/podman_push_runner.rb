# frozen_string_literal: true

require 'uri'
require 'smart_proxy_dynflow/runner/process_manager_command'
require_relative '../helpers/ansible_navigator_helpers'

module Proxy
  module AnsibleDirector
    module Runners
      class PodmanPushRunner < ::Proxy::Dynflow::Runner::Base
        include ::Proxy::Dynflow::Runner::ProcessManagerCommand

        def initialize(podman_push_input, suspended_action: nil)
          super suspended_action: suspended_action
          @ee_id = podman_push_input[:ee_id]
          @cert_dir = nil
        end

        def start
          registry = URI.parse(Proxy::SETTINGS.foreman_url).host
          image_name = "ansible_director/#{@ee_id}:latest"

          @cert_dir = ::Proxy::ContainerRegistry::PodmanAuth.setup_cert_dir
          tls_args = ::Proxy::ContainerRegistry::PodmanAuth.tls_args(@cert_dir)

          cmd = "podman push #{tls_args} #{image_name} #{registry}/#{image_name}"
          initialize_command('bash', '-c', cmd)
        end

        def refresh
          @process_manager.process(timeout: 0.1) unless @process_manager.done?
          puts @continuous_output.humanize
          publish_exit_status(@process_manager.status) if @process_manager.done?
        end

        def close
          ::Proxy::ContainerRegistry::PodmanAuth.cleanup(@cert_dir)
        end

        def publish_data(message, type = 'debug')
            @continuous_output.add_output(message.force_encoding('UTF-8'), type)
        end
      end
    end
  end
end
