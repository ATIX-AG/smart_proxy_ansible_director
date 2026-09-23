# frozen_string_literal: true

require_relative 'version'
require 'fileutils'

module Proxy
  module AnsibleDirector
    class Plugin < Proxy::Plugin
      plugin :ansible_director, ::Proxy::AnsibleDirector::VERSION
      rackup_path File.expand_path('http_config.ru', __dir__)

      default_settings(
        workdir_root: "/usr/share/foreman-proxy/.ansible_director",
        ansible_navigator_run_dir: "run",
        execution_env_build_dir: "execution_env",
        remove_workdirs: true
      )

      load_classes do
        require 'smart_proxy_dynflow'
        require 'smart_proxy_ansible_director/launchers'
        require 'smart_proxy_ansible_director/actions'
        require 'smart_proxy_ansible_director/runners'
      end

      after_activation do
        FileUtils.mkdir_p(
          Proxy::AnsibleDirector::Plugin.settings[:workdir_root]
        )

        [
          Proxy::AnsibleDirector::Plugin.settings[:ansible_navigator_run_dir],
          Proxy::AnsibleDirector::Plugin.settings[:execution_env_build_dir],
          "certs"
        ].each do |dir|
          FileUtils.mkdir_p(
            File.join(
              Proxy::AnsibleDirector::Plugin.settings[:workdir_root],
              dir
            )
          )
        end

        # This symlinks the foreman client certs to the new directory, as the certificates have to adhere to a specific
        # naming scheme.
        # See: https://man.archlinux.org/man/containers-certs.d.5.en#Directory_Structure
        FileUtils.ln_sf(Proxy::SETTINGS.foreman_ssl_cert, File.join(
                                                            Proxy::AnsibleDirector::Plugin.settings[:workdir_root],
                                                            "certs",
                                                            "client.cert"
                                                          ))
        FileUtils.ln_sf(Proxy::SETTINGS.foreman_ssl_ca, File.join(
                                                          Proxy::AnsibleDirector::Plugin.settings[:workdir_root],
                                                          "certs",
                                                          "ca.crt"
                                                        ))
        FileUtils.ln_sf(Proxy::SETTINGS.foreman_ssl_key, File.join(
                                                           Proxy::AnsibleDirector::Plugin.settings[:workdir_root],
                                                           "certs",
                                                           "client.key"
                                                         ))

        Proxy::Dynflow::TaskLauncherRegistry.register('ansible-builder',
                                                      ::Proxy::AnsibleDirector::Launchers::AnsibleBuilderLauncher)
        Proxy::Dynflow::TaskLauncherRegistry.register('ansible-navigator',
                                                      ::Proxy::AnsibleDirector::Launchers::AnsibleNavigatorLauncher)
        Proxy::Dynflow::TaskLauncherRegistry.register('meta', ::Proxy::AnsibleDirector::Launchers::MetaLauncher)
      end

      # Settings listed under default_settings are required.
      # An exception will be raised if they are initialized with nil values.
      # Settings not listed under default_settings are considered optional and by default have nil value.
      # default_settings required_setting: 'default_value', required_path: '/must/exist'

      # Verifies that a file exists and is readable.
      # Uninitialized optional settings will not trigger validation errors.
      # validate_readable :required_path, :optional_path
    end
  end
end
