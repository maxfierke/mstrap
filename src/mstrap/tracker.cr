module MStrap
  module Tracker
    class Noop
      def initialize(_options)
      end

      def identify
      end

      def track(_event_title, _data = nil)
      end
    end

    def self.for(options)
      MStrap::Tracker::Noop.new(options)
    end
  end
end
