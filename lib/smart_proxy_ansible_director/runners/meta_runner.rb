# frozen_string_literal: true

require_relative '../runners'

module Proxy
  module AnsibleDirector
    module Runners
      class MetaRunner < ::Proxy::Dynflow::Runner::Base
        PHASES = [
          { id: :build_ee, title: 'Building execution environment', runner_class: AnsibleBuilderRunner,
            runner_input_key: :build_ee_input },
          { id: :run_ansible, title: 'Running Ansible', runner_class: AnsibleNavigatorRunner,
            runner_input_key: :run_ansible_input }
        ].freeze

        def initialize(input, suspended_action: nil)
          super(suspended_action: suspended_action)
          @input = input
          @phase_index = 0
          @current_runner = nil
        end

        def start
          transition_to_phase(@phase_index)
        end

        def refresh
          return unless @current_runner

          @current_runner.refresh

          @continuous_output.raw_outputs.concat(@current_runner.continuous_output.raw_outputs)
          @current_runner.continuous_output.raw_outputs.clear

          return unless @current_runner.exit_status

          if @current_runner.exit_status != 0
            publish_exit_status(@current_runner.exit_status)
          else
            transition_to_next_phase
          end
        end

        def kill
          @current_runner&.kill
        end

        def close
          @current_runner&.close
        end

        private

        def transition_to_phase(index)
          phase_info = PHASES[index]

          @phase_index = index
          runner_class = phase_info[:runner_class]
          runner_input = @input[phase_info[:runner_input_key]]

          @continuous_output.add_output(
            "START: Phase #{phase_info[:id]} (#{index + 1} / #{PHASES.length}): #{phase_info[:title]}\n"
          )

          @current_runner = runner_class.new(runner_input, suspended_action: @suspended_action)
          @current_runner.start
        end

        def transition_to_next_phase
          phase_info = PHASES[@phase_index]
          @continuous_output.add_output(
            "END: Phase #{phase_info[:id]}: #{phase_info[:title]}\n"
          )

          if @phase_index + 1 < PHASES.length
            @phase_index += 1
            transition_to_phase(@phase_index)
          else
            publish_exit_status(0)
          end
        end
      end
    end
  end
end
