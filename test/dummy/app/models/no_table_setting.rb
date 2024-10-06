# frozen_string_literal: true

# This case for valid use Setting before Rails migration
class NoTableSetting < RailsAppSettings::Base
  self.table_name = "not-exist-settings"

  field :foo, type: :string, default: "Hello world"
end
