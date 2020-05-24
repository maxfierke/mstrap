module MStrap
  module Steps
    # Runnable as `mstrap steps`, the Steps step simply prints a list of steps
    # supported by `mstrap`.
    class StepsStep < Step
      def self.description
        "Prints available steps"
      end

      def self.requires_mstrap?
        false
      end

      def bootstrap
        logn "Available steps: "
        logn "#{Step.all.keys.map(&.to_s).join(", ")}"
        exit 0
      end
    end
  end
end
