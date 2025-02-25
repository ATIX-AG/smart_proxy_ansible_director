source 'https://rubygems.org'

gemspec

group :development do
  gem 'rack-test'
  gem 'smart_proxy', github: 'theforeman/smart-proxy',
                     branch: ENV.fetch('SMART_PROXY_BRANCH', 'develop')
  gem 'webrick'
end
