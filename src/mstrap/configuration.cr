module MStrap
  class Configuration
    class ConfigurationLoadError < Exception; end
    class ConfigurationNotFoundError < ConfigurationLoadError
      def initialize(path : String)
        super("#{path} does not exist or is not accessible.")
      end
    end

    include Utils::Env
    include Utils::System

    @cli : CLIOptions
    @config_yaml_def : Defs::ConfigDef
    @loaded_profile_configs : Array(Defs::ProfileConfigDef)
    @loaded_profiles : Array(Defs::ProfileDef)
    @known_profile_configs : Array(Defs::ProfileConfigDef)
    @resolved_profile : Defs::ProfileDef
    @user : User

    DEFAULT_PROFILE_DEF = Defs::DefaultProfileDef.new

    getter :cli,
      :known_profile_configs,
      :loaded_profile_configs,
      :loaded_profiles,
      :resolved_profile,
      :user

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

    def load_profiles!
      return self if loaded_profiles?

      known_profile_configs.each do |profile_config|
        if profile_config == DEFAULT_PROFILE_DEF
          next if !File.exists?(profile_config.path)
        else
          fetcher = ProfileFetcher.new(profile_config)

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

    def loaded_profiles?
      loaded_profiles.any?
    end

    def profile_configs
      loaded_profile_configs
    end

    def profiles
      loaded_profiles
    end

    def reload!
      if File.exists?(cli.config_path)
        config_yaml = File.read(cli.config_path)
        config = Defs::ConfigDef.from_yaml(config_yaml)

        # TODO: This is gross, but the initialization logic can't happen inside
        # another method for types to be correctly inferred (w/o making them nilable)
        initialize(cli, config, github_access_token)
        load_profiles!
      else
        raise ConfigurationNotFoundError.new(cli.config_path)
      end
    end

    def save!
      config_yaml = @config_yaml_def.to_yaml

      if cli.config_path.starts_with?("https://")
        path = Paths::SERVICES_YML
      else
        path = cli.config_path
      end

      File.write(path, config_yaml, perm: 0o600)
    end

    private getter :github_access_token

    private def resolve_profile!
      resolved_profile.merge!(profiles)
    end

    private def has_git?
      cmd("command -v git > /dev/null 2>&1")
    end
  end
end
