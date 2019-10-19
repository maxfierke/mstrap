module MStrap
  module Steps
    class UpdateProfilesStep < Step
      include Utils::Logging
      include Utils::System

      def self.description
        "Update profiles"
      end

      def self.requires_mstrap?
        false
      end

      def bootstrap
        log "---> Updating profiles: "
        config.reload!
        config.save!
        success "OK"
      end
    end
  end
end
