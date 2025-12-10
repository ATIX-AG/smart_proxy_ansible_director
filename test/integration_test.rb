# frozen_string_literal: true

require 'test_helper'
require 'root/root_v2_api'
require 'smart_proxy_ansible_director'

# Test that the plugin loads and the Smart Proxy reports the correct feature
class AnsibleDirectorFeaturesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Proxy::PluginInitializer.new(Proxy::Plugins.instance).initialize_plugins
    Proxy::RootV2Api.new
  end

  def load_config(*args, **kwargs)
    Proxy::DefaultModuleLoader.any_instance.expects(:load_configuration_file).with('ansible_director.yml').returns(
      *args, **kwargs
    )
  end

  def failed_module_log
    Proxy::LogBuffer::Buffer.instance.info[:failed_modules][:pulsible]
  end

  def get_feature
    get '/features'
    assert last_response.ok?, "Last response was not ok: #{last_response.body}"
    response = JSON.parse(last_response.body)
    feature = response['pulsible']
    refute_nil(feature)
    feature
  end

  #   def test_features_with_file_missing
  #     load_config(enabled: true)
  #
  #     feature = get_feature
  #
  #     assert_equal('failed', feature['state'], failed_module_log)
  #     assert_equal(
  #       "Disabling all modules in the group ['ansible_director'] due to a failure in one of them:
  #  File at '/must/exist' defined in 'required_path' parameter doesn't exist or is unreadable", failed_module_log
  #     )
  #   end
  #
  #   def test_features_with_file_present
  #     Tempfile.create do |tmpfile|
  #       load_config(enabled: true, required_path: tmpfile.path)
  #
  #       feature = get_feature
  #
  #       assert_equal('running', feature['state'], failed_module_log)
  #       # https://theforeman.org/2019/04/smart-proxy-capabilities-explained.html
  #       assert_equal({}, feature['settings'], 'There are no exposed settings')
  #       assert_equal([], feature['capabilities'], 'There are no exposed capabilities')
  #     end
  #   end
end
