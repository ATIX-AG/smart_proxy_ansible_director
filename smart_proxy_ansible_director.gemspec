require File.expand_path('lib/smart_proxy_ansible_director/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_ansible_director'
  s.version     = Proxy::AnsibleDirector::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Thorben Denzer']
  s.email       = ['denzer@atix.de']
  s.homepage    = 'https://example.com'

  s.summary     = "A Plugin for Foreman's smart proxy"
  s.description = "A longer description of the plugin for Foreman's smart proxy"

  s.files       = Dir[
      '{lib/smart_proxy_ansible_director,bundler.d,settings.d}/**/*',
      'lib/smart_proxy_ansible_director.rb'
  ] + %w[README.md LICENSE]
  s.require_paths = ['lib']
  s.test_files  = s.files.grep(%r{^(test|spec|features)/})

  s.add_runtime_dependency('smart_proxy_dynflow', '~> 0.9')

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
