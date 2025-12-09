require_relative '../pull_execution_environment'
require 'smart_proxy_dynflow/callback'

module Proxy
    module AnsibleDirector
        module Actions
            module Meta

                class RunAnsibleScript < ::Proxy::Dynflow::Action::Runner


                    def plan(args)

                        script = args["script"]
                        execution_environment = args["execution_environment"]
                        inventory = args["inventory"]


                        sequence do
                            _pull_ee_action = plan_action ::Proxy::AnsibleDirector::Actions::PullExecutionEnvironment, {
                                ee_registry_url: execution_environment
                            }
                            run_ansible_action = plan_action ::Proxy::AnsibleDirector::Actions::RunAnsibleNavigator, {
                                mode: "literal",
                                inventory: inventory,
                                playbook: script,
                                execution_environment: "#{execution_environment.split('/')[-1]}:latest",
                            }
                            plan_action ::Proxy::Dynflow::Callback::Action,
                                        args[:callback],
                                        run_ansible_action.output
                        end
                    end
                end
            end
        end
    end
end
