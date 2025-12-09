

module Proxy
    module AnsibleDirector
        module Actions
            class PullExecutionEnvironment < ::Proxy::Dynflow::Action::Runner

                def plan(pull_ee_input)
                    plan_self pull_ee_input: pull_ee_input
                end

                def initiate_runner
                    ::Proxy::AnsibleDirector::Runners::PodmanPullRunner.new(input[:pull_ee_input])
                end
            end
        end
    end
end