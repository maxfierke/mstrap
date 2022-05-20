module MStrap
  # Base class for mstrap exceptions
  class MStrapError < Exception; end

  # Exception class for configuration load errors
  class ConfigurationLoadError < MStrapError; end

  # Exception raised if configuration file is not found or is inaccessible.
  class ConfigurationNotFoundError < ConfigurationLoadError
    def initialize(path : String)
      super("#{path} does not exist or is not accessible.")
    end
  end

  # Exception class to indicate some failure fetching a profile
  class ProfileFetchError < MStrapError; end

  # Exception class for Git-related profile fetch errors
  class GitProfileFetchError < ProfileFetchError
    def initialize(config)
      super("#{config.name}: Could not clone profile via git. Ensure you have access.")
    end
  end

  # Exception class to indicate an invalid URL for a profile
  class InvalidProfileUrlError < ProfileFetchError; end

  # Exception class for profile checksum mismatches
  class ProfileChecksumMismatchError < ProfileFetchError
    def initialize(config)
      super("#{config.name}: Could not fetch profile due to checksum mismatch. The remote contents may have changed. Please verify and update `revision` with latest checksum.")
    end
  end

  # Exception class to indicate a failure involving language runtime setup
  class RuntimeSetupError < MStrapError
    def initialize(language_name, message)
      super("#{language_name}: #{message}")
    end
  end
end
