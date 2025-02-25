require_relative 'version'

module Proxy
  module Pulsible
    class Plugin < ::Proxy::Plugin
      plugin :pulsible, ::Proxy::Pulsible::VERSION
      rackup_path File.expand_path('http_config.ru', __dir__)

      # Settings listed under default_settings are required.
      # An exception will be raised if they are initialized with nil values.
      # Settings not listed under default_settings are considered optional and by default have nil value.
      default_settings required_setting: 'default_value', required_path: '/must/exist'

      # Verifies that a file exists and is readable.
      # Uninitialized optional settings will not trigger validation errors.
      validate_readable :required_path, :optional_path
    end
  end
end
