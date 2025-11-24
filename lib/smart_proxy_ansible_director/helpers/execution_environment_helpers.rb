# frozen_string_literal: true

module Proxy
  module AnsibleDirector
    module Helpers
      class ExecutionEnvironmentHelpers
        class << self
          def format_content(content_units)
            collections = []
            roles = []

            content_units.each do |content_unit|
              formatted_unit = {
                name: content_unit['identifier'],
                version: content_unit['version'],
                source: content_unit['source']
              }

              case content_unit['type']
              when 'collection'
                collections << formatted_unit
              when 'role'
                roles << formatted_unit
              end
            end
            {
              collections: collections.length.positive? ? collections : nil,
              roles: roles.length.positive? ? roles : nil
            }.compact!
          end

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
