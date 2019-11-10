module MStrap
  class Configuration

    # Exception class for configuration load errors
    class ConfigurationLoadError < Exception; end

    # Exception raised if configuration file is not found or is inaccessible.
    class ConfigurationNotFoundError < ConfigurationLoadError
      def initialize(path : String)
        super("#{path} does not exist or is not accessible.")
      end
    end

    include Utils::Env
    include Utils::Logging
    include Utils::System

    @cli : CLIOptions
    @config_yaml_def : Defs::ConfigDef
    @loaded_profile_configs : Array(Defs::ProfileConfigDef)
    @loaded_profiles : Array(Defs::ProfileDef)
    @known_profile_configs : Array(Defs::ProfileConfigDef)
    @resolved_profile : Defs::ProfileDef
    @user : User

    DEFAULT_PROFILE_DEF = Defs::DefaultProfileDef.new

    # Returns CLI options
    getter :cli

    # Returns known profile configurations
    getter :known_profile_configs

    # Returns loaded profile configurations
    getter :loaded_profile_configs

    # Returns loaded profiles
    getter :loaded_profiles

    # Returns resolved profile. This is the result of merging loaded managed
    # profiles with the default profiles.
    getter :resolved_profile

    # Returns the mstrap user
    getter :user

    def initialize(cli : CLIOptions, config : Defs::ConfigDef, github_access_token : String? = nil)
      @cli = cli
      @config_yaml_def = config
      @loaded_profile_configs = [] of Defs::ProfileConfigDef
      @loaded_profiles = [] of Defs::ProfileDef
      @known_profile_configs = config.profiles + [DEFAULT_PROFILE_DEF]
      @resolved_profile = Defs::ProfileDef.new
      @github_access_token = github_access_token
      @user = User.new(user: config.user, github_access_token: github_access_token)
    end

    # Loads all profiles and resolves them into the resolve_profile
    #
    # Raises ConfigurationNotFoundError if a profile cannot be found.
    def load_profiles!(force = nil)
      return self if loaded_profiles?

      known_profile_configs.each do |profile_config|
        if profile_config == DEFAULT_PROFILE_DEF
          next if !File.exists?(profile_config.path)
        else
          fetcher = ProfileFetcher.new(profile_config, force || cli.force?)

          if !mstrapped? && fetcher.git_url? && !has_git?
            logw "Skipping profile '#{profile_config.name}' fetch, as git has not yet been installed."
            logw "This should be okay, as it will be fetched & loaded following installation of git via strap.sh"
            next
          end

          fetcher.fetch!

          if !File.exists?(profile_config.path)
            raise ConfigurationNotFoundError.new(profile_config.path)
          end
        end

        profile_yaml = File.read(profile_config.path)

        loaded_profile_configs << profile_config
        loaded_profiles << Defs::ProfileDef.from_yaml(profile_yaml)
      end

      resolve_profile!

      self
    end

    # Returns whether profiles have been loaded
    def loaded_profiles?
      loaded_profiles.any?
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
    def reload!(force = nil)
      if File.exists?(config_path)
        config_yaml = File.read(config_path)
        config = Defs::ConfigDef.from_yaml(config_yaml)

        # TODO: This is gross, but the initialization logic can't happen inside
        # another method for types to be correctly inferred (w/o making them nilable)
        initialize(cli, config, github_access_token)
        load_profiles!(force)
      else
        raise ConfigurationNotFoundError.new(config_path)
      end
    end

    # Saves configuration back to disk
    def save!
      config_yaml = @config_yaml_def.to_yaml
      FileUtils.mkdir_p(Paths::RC_DIR, 0o755)
      File.write(config_path, config_yaml, perm: 0o600)
    end

    private getter :github_access_token

    private def config_path
      if cli.config_path.starts_with?("https://")
        Paths::CONFIG_YML
      else
        cli.config_path
      end
    end

    private def resolve_profile!
      resolved_profile.merge!(profiles)
    end

    private def has_git?
      cmd("command -v git > /dev/null 2>&1")
    end
  end
end
