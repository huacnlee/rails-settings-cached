module RailsSettings
  module Fields
    class Custom < ::RailsSettings::Fields::Base
      def serialize(value)
        case value
        when 'a', 1 then 'a'
        when 'b', 2 then 'b'
        when 'c', 3 then 'c'
        else raise StandardError, 'invalid value'
        end
      end

      def deserialize(value)
        case value
        when 'a', 1 then 1
        when 'b', 2 then 2
        when 'c', 3 then 3
        else nil
        end
      end
    end
  end
end
