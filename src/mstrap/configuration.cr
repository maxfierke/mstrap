module MStrap
  class Configuration
    include DSL

    @config_def : Defs::ConfigDef
    @default_runtime_manager : RuntimeManager
    @loaded_profile_configs : Array(Defs::ProfileConfigDef)
    @loaded_profiles : Array(Defs::ProfileDef)
    @known_profile_configs : Array(Defs::ProfileConfigDef)
    @resolved_profile : Defs::ProfileDef
    @runtime_managers : Array(RuntimeManager)
    @runtimes : Hash(String, Runtime)
    @user : User

    DEFAULT_PROFILE_CONFIG_DEF = Defs::DefaultProfileConfigDef.new

    # Returns path to configuration file
    getter :config_path

    # Returns known profile configurations
    getter :known_profile_configs

    # Returns loaded profile configurations
    getter :loaded_profile_configs

    # Returns loaded profiles
    getter :loaded_profiles

    # Returns resolved profile. This is the result of merging loaded managed
    # profiles with the default profiles.
    getter :resolved_profile

    # Returns the default runtime manager specified by the configuration
    getter :default_runtime_manager

    # Returns the runtime managers specified by the configuration
    getter :runtime_managers

    # Returns the language runtimes with their resolved runtime manager
    #
    # Raises UnsupportedLanguageRuntimeManagerError if the configuration of a
    # language runtime to a runtime manager is invalid
    # Raises InvalidRuntimeManagerError if an invalid runtime manager is provided
    getter :runtimes

    # Returns the mstrap user
    getter :user

    def initialize(
      config : Defs::ConfigDef,
      config_path : String = Paths::CONFIG_HCL,
    )
      @config_def = config
      @config_path = config_path
      @default_runtime_manager = RuntimeManager.for(config.runtimes.default_manager)
      @loaded_profile_configs = [] of Defs::ProfileConfigDef
      @loaded_profiles = [] of Defs::ProfileDef
      @known_profile_configs = config.profiles + [DEFAULT_PROFILE_CONFIG_DEF]
      @resolved_profile = Defs::ProfileDef.new
      @runtime_managers = RuntimeManager.resolve_managers(config)
      @runtimes = RuntimeManager.resolve_runtimes(config)
      @user = User.new(user: config.user)
    end

    # Loads all profiles and resolves them into the resolved_profile
    #
    # Raises ConfigurationNotFoundError if a profile cannot be found.
    def load_profiles!(force = false)
      return self if loaded_profiles?

      known_profile_configs.each do |profile_config|
        if profile_config == DEFAULT_PROFILE_CONFIG_DEF
          # Ignore but treat as loaded
          if !File.exists?(profile_config.path)
            loaded_profile_configs << profile_config
            next
          end
        else
          begin
            fetcher = ProfileFetcher.new(profile_config, force: force)
          rescue ex : URI::Error
            logc <<-ERR
An error occurred while trying to parse the URL for the '#{profile_config.name}' profile:"
#{ex.message}

The URL provided was '#{profile_config.url}'. Please double-check you have provided a valid
URL according to the WHATWG URL Standard.
ERR
          end

          if !MStrap.mstrapped? && fetcher.git_url? && !MStrap::Platform.has_git?
            logw "Skipping profile '#{profile_config.name}' fetch, as git has not yet been installed."
            logw "This should be okay, as it will be fetched & loaded following installation of git via strap.sh"
            next
          end

          fetcher.fetch!

          if !File.exists?(profile_config.path)
            raise ConfigurationNotFoundError.new(profile_config.path)
          end
        end

        profile_hcl = File.read(profile_config.path)

        loaded_profile_configs << profile_config
        loaded_profiles << Defs::ProfileDef.from_hcl(profile_hcl)
      end

      resolve_profile!

      self
    end

    # Returns whether profiles have been loaded
    def loaded_profiles?
      !loaded_profiles.empty?
    end

    # Returns profile configurations for active profiles
    def profile_configs
      loaded_profile_configs
    end

    # Returns active profiles
    def profiles
      loaded_profiles
    end

    # Resets and reloads configuration and any managed profiles.
    #
    # Raises ConfigurationNotFoundError if the mstrap configuration cannot be
    # found or accessed, or any managed profiles cannot be found or accessed.
    def reload!(force = false)
      if File.exists?(config_path)
        config_hcl = File.read(config_path)
        config = Defs::ConfigDef.from_hcl(config_hcl)

        # TODO: This is gross, but the initialization logic can't happen inside
        # another method for types to be correctly inferred (w/o making them nilable)
        initialize(config, config_path)
        load_profiles!(force: force)
      else
        raise ConfigurationNotFoundError.new(config_path)
      end
    end

    # Saves configuration back to disk
    def save!
      config_hcl = @config_def.to_hcl
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      File.write(config_path, config_hcl, perm: 0o600)
    end

    private def resolve_profile!
      resolved_profile.merge!(profiles)
    end
  end
end
