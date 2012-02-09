require 'rubygems'
require "rspec"
require "active_record"
require 'active_support'
require "rails/railtie"


ENV["RAILS_ENV"] ||= 'test'

module Rails
  def self.cache
    @cache ||= ActiveSupport::Cache::MemoryStore.new
  end
  
  def self.version
    "3"
  end
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :settings do |t|
    t.string :var, :null => false
    t.text :value
    t.integer :thing_id
    t.string :thing_type, :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "rails-settings-cached"

RSpec.configure do |config|
  config.before(:each) do
    class ::Setting < RailsSettings::CachedSettings
    end
    
    ::Setting.destroy_all
    Rails.cache.clear
  end
  
  config.after(:each) do
    Object.send(:remove_const, :Setting)
  end
end

