# frozen_string_literal: true

# This case for valid use Setting before Rails migration
class NoTableSetting < RailsSettings::Base
  cache_prefix { "v1" }

  self.table_name = "not-exist-settings"

  field :foo, type: :string, default: "Hello world"
end
