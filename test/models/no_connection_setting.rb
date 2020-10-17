# frozen_string_literal: true

# This case for valid use Setting without database connection
class NoConnectionSetting < RailsSettings::Base
  establish_connection "postgres://localhost:11111/not-exist-connection"

  field :bar, type: :string, default: "Hello world"
end
