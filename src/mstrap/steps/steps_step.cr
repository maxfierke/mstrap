module MStrap
  class StepsStep < Step
    include Utils::Logging

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
