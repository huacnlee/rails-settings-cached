# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  test "configuration" do
    RailsAppSettings.configure do
      self.cache_storage = ActiveSupport::Cache.lookup_store(:dummy_store)
    end

    assert RailsAppSettings.config.cache_storage.instance_of? ActiveSupport::Cache::DummyStore
  end
end
