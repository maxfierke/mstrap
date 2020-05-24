module MStrap
  module Steps
    # Runnable as `mstrap update-profiles`, the Update Profiles step updates
    # installed managed profiles.
    class UpdateProfilesStep < Step
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
