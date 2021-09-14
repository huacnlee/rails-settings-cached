# frozen_string_literal: true

# This case for valid use Setting without database connection
class NoConnectionSetting < RailsSettings::Base
  establish_connection adapter: "postgresql"

  field :bar, type: :string, default: "Hello world"
end
