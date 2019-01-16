module MStrap
  module Steps
    class DebugStep < Step
      def self.requires_mstrap?
        false
      end

      def bootstrap
        puts "mstrap v#{MStrap::VERSION}"
        pp! Step.all
      end
    end
  end
end
