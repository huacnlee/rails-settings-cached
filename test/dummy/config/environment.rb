# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# Config for use in memory database
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
