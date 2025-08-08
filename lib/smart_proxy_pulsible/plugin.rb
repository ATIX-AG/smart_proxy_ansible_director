require_relative 'version'

module Proxy
  module Pulsible
    class Plugin < ::Proxy::Plugin
      plugin :pulsible, ::Proxy::Pulsible::VERSION
      rackup_path File.expand_path('http_config.ru', __dir__)


      load_classes do
        require 'smart_proxy_dynflow'
        require 'smart_proxy_pulsible/launchers'
        require 'smart_proxy_pulsible/actions'
        require 'smart_proxy_pulsible/runners'
      end

      load_dependency_injection_wirings do |_container_instance, _settings|
        Proxy::Dynflow::TaskLauncherRegistry.register('ansible-builder', ::Proxy::Pulsible::Launchers::AnsibleBuilderLauncher)
        Proxy::Dynflow::TaskLauncherRegistry.register('ansible-navigator', ::Proxy::Pulsible::Launchers::AnsibleNavigatorLauncher)
        Proxy::Dynflow::TaskLauncherRegistry.register('meta', ::Proxy::Pulsible::Launchers::MetaLauncher)
      end

      # Settings listed under default_settings are required.
      # An exception will be raised if they are initialized with nil values.
      # Settings not listed under default_settings are considered optional and by default have nil value.
      #default_settings required_setting: 'default_value', required_path: '/must/exist'

      # Verifies that a file exists and is readable.
      # Uninitialized optional settings will not trigger validation errors.
      #validate_readable :required_path, :optional_path
    end
  end
end
