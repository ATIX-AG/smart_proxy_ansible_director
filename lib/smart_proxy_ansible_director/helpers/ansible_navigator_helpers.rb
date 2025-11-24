# frozen_string_literal: true

module Proxy
  module AnsibleDirector
    module Helpers
      class AnsibleNavigatorHelpers
        class << self
          def reserialize_inventory(inventory_json)
            YAML.dump(JSON.parse(inventory_json.to_h.to_json))
          end

          def reserialize_playbook(playbook_json)
            YAML.dump(JSON.parse(playbook_json.to_json))
          end

          def reserialize_execution_environment(execution_environment_json)
            YAML.dump(JSON.parse(execution_environment_json.to_h.to_json))
          end
        end
      end
    end
  end
end
