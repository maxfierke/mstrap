module MStrap
  class Configuration
    class ConfigurationLoadError < Exception; end
    class ConfigurationNotFoundError < ConfigurationLoadError
      def initialize(path : String)
        super("#{path} does not exist or is not accessible.")
      end
    end


    @cli : CLIOptions
    @config_yaml_def : Defs::ConfigDef
    @profile_configs : Array(Defs::ProfileConfigDef)
    @profiles : Array(Defs::ProfileDef)
    @resolved_profile : Defs::ProfileDef
    @user : User

    DEFAULT_PROFILE_DEF = Defs::DefaultProfileDef.new

    getter :cli, :profile_configs, :profiles, :resolved_profile, :user

    def initialize(cli : CLIOptions, config : Defs::ConfigDef, github_access_token : String? = nil)
      @cli = cli
      @config_yaml_def = config
      @profile_configs = [DEFAULT_PROFILE_DEF] + config.profiles
      @profiles = [] of Defs::ProfileDef
      @resolved_profile = Defs::ProfileDef.new
      @github_access_token = github_access_token
      @user = User.new(user: config.user, github_access_token: github_access_token)
    end

    def load_profiles!
      return self if loaded_profiles?

      profile_configs.each do |profile_config|
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
        profiles << Defs::ProfileDef.from_yaml(profile_yaml)
      end

      resolve_profile!

      self
    end

    def loaded_profiles?
      profiles.any?
    end

    def reload!
      if File.exists?(cli.config_path)
        config_yaml = File.read(cli.config_path)
        config = Defs::ConfigDef.from_yaml(config_yaml)

        # TODO: DRY this up?
        @config_yaml_def = config
        @profile_configs = [DEFAULT_PROFILE_DEF] + config.profiles
        @profiles = [] of Defs::ProfileDef
        @resolved_profile = Defs::ProfileDef.new
        @user = User.new(user: config.user, github_access_token: github_access_token)
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
