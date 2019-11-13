module MStrap
  module Steps
    # Runnable as `mstrap update-profiles`, the Update Profiles step updates
    # installed managed profiles.
    class UpdateProfilesStep < Step
      include Utils::Env
      include Utils::Logging
      include Utils::System

      def self.description
        "Update profiles"
      end

      def self.requires_mstrap?
        false
      end

      def bootstrap
        log "--> Updating profiles: "
        config.reload!(force: true)
        config.save!
        success "OK"
      end
    end
  end
end
