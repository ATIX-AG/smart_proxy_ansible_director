require 'test/unit'
require 'mocha/test_unit'
require 'rack/test'

require 'smart_proxy_for_testing'

ENV['RACK_ENV'] = 'test'

# create log directory in our (not smart-proxy) directory
FileUtils.mkdir_p File.dirname(Proxy::SETTINGS.log_file)
