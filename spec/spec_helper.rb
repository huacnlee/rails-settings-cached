require 'rspec/autorun'
require 'rails/all'
require 'sqlite3'
require_relative '../lib/rails-settings-cached'

module Rails
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
end

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
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table :users do |t|
    t.string :login
    t.string :password
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end
end

RSpec.configure do |config|
  config.before(:all) do
    class Setting < RailsSettings::CachedSettings
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
