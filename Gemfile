# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :rubocop do
  gem 'rubocop', '~> 1.28.0'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
end

group :development do
  gem 'rack-test'
  gem 'smart_proxy', github: 'theforeman/smart-proxy', branch: ENV.fetch('SMART_PROXY_BRANCH', 'develop')
  gem 'webrick'
end
