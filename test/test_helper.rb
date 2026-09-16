# frozen_string_literal: true

# Must start before the gem is loaded, so every file in lib/ is tracked.
require "simplecov"
if ENV["CI"]
  # Cobertura XML (coverage/coverage.xml) is uploaded to Codecov by the CI workflow.
  require "simplecov-cobertura"
  SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::CoberturaFormatter]
end
SimpleCov.start do
  enable_coverage :branch
  add_filter "/test/"
  # Templates are copied into apps, not run; version.rb is loaded by the gemspec before this point.
  add_filter "/lib/generators/settings/templates/"
  add_filter "/lib/rails-settings/version.rb"
  track_files "lib/**/*.rb"
end

require "minitest/autorun"

require File.expand_path("../test/dummy/config/environment.rb", __dir__)

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

class ActiveSupport::TestCase
  teardown do
    Setting.destroy_all
  end

  def assert_number_of_queries(count, &block)
    queries_count = 0
    queries = []

    counter_f = lambda do |_name, _started, _finished, _unique_id, payload|
      unless payload[:name].in? %w[CACHE SCHEMA]
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

  def assert_errors_on(model, key, messages)
    messages = Array(messages) unless messages.is_a?(Array)
    assert_equal true, model.errors.has_key?(key), "#{model.errors.messages.keys} not include #{key}"
    assert_equal messages, model.errors.full_messages_for(key)
  end

  def assert_raise_with_validation_message(message)
    ex = assert_raise(ActiveRecord::RecordInvalid) { yield }
    assert_equal message, ex.message
  end
end
