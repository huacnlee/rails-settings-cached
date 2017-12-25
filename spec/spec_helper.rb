$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'rspec'
require 'rails/all'
require 'sqlite3'

require 'simplecov'
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start

require 'rails-settings-cached'

if RailsSettings::Settings.respond_to? :raise_in_transactional_callbacks=
  RailsSettings::Settings.raise_in_transactional_callbacks = true
end

class TestApplication < Rails::Application
end

module Rails
  def self.root
    Pathname.new(File.expand_path('../', __FILE__))
  end

  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end

  def self.env
    'test'
  end
end

def count_queries(&block)
  count = 0

  counter_f = lambda do |_name, _started, _finished, _unique_id, payload|
    count += 1 unless payload[:name].in? %w[CACHE SCHEMA]
  end

  ActiveSupport::Notifications.subscribed(counter_f, 'sql.active_record', &block)

  count
end

# run cache initializers
RailsSettings::Railtie.initializers.each(&:run)

# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
# ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(version: 1) do
  create_table :settings do |t|
    t.string :var, null: false
    t.text :value
    t.integer :thing_id
    t.string :thing_type, limit: 30
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :users do |t|
    t.string :login
    t.string :password
    t.datetime :created_at
    t.datetime :updated_at
  end
end

RSpec.configure do |config|
  config.before(:all) do
    class Setting < RailsSettings::Base
    end

    class CustomSetting < RailsSettings::Base
    end

    class User < ActiveRecord::Base
      include RailsSettings::Extend
    end

    ActiveRecord::Base.connection.execute('delete from settings')
    Rails.cache.clear
  end

  config.after(:all) do
    Object.send(:remove_const, :Setting)
  end
end

Rails.application.instance_variable_set('@initialized', true)
