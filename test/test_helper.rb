# frozen_string_literal: true

require "minitest/autorun"
require "rails/all"
require "sqlite3"
require "rails-settings-cached"

require "simplecov"
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

require_relative "./models/setting"

# Hit readonly field before Rails initialize
Setting.readonly_item
Setting.omniauth_google_options

class TestApplication < Rails::Application
end

module Rails
  def self.root
    Pathname.new(File.expand_path("../", __FILE__))
  end

  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  def self.env
    "test"
  end
end

# run cache initializers
RailsSettings::Railtie.initializers.each(&:run)
Rails.application.instance_variable_set("@initialized", true)

# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(version: 1) do
  create_table :settings do |t|
    t.string :var, null: false
    t.text :value
    t.datetime :created_at
    t.datetime :updated_at
  end
end

class ActiveSupport::TestCase
  teardown do
    Setting.unscoped.destroy_all
    Rails.cache.clear
  end

  def assert_number_of_queries(count, &block)
    queries_count = 0
    queries = []

    counter_f = lambda do |_name, _started, _finished, _unique_id, payload|
      if !payload[:name].in? %w(CACHE SCHEMA)
        queries_count += 1
        queries << payload
       end
    end

    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &block)

    assert_equal count, queries_count, message: queries.join("\n")
  end

  def assert_no_queries(&block)
    assert_number_of_queries 0, &block
  end
end
