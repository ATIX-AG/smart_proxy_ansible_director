require File.expand_path('lib/smart_proxy_ansible_director/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_ansible_director'
  s.version     = Proxy::AnsibleDirector::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Thorben Denzer']
  s.email       = ['denzer@atix.de']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_pulsible'

  s.summary     = "A Plugin for Foreman's smart proxy"
  s.description = "A longer description of the plugin for Foreman's smart proxy"

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
