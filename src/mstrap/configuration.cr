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

    DEFAULT_PROFILE_DEF = Defs::ProfileConfigDef.new(
      name: "default",
      url: "file://profile.yml"
    )

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
      profile_configs.each do |profile_config|
        ProfileFetcher.new(profile_config).fetch!

        if !File.exists?(profile_config.path)
          next if profile_config == DEFAULT_PROFILE_DEF
          raise ConfigurationNotFoundError.new(profile_config.path)
        end

        profile_yaml = File.read(profile_config.path)
        profiles << Defs::ProfileDef.from_yaml(profile_yaml)
      end

      resolve_profile!

      self
    end

    def reload!
      if File.exists?(Paths::CONFIG_YML)
        config_yaml = File.read(Paths::CONFIG_YML)
        config = Defs::ConfigDef.from_yaml(config_yaml)

        # TODO: DRY this up?
        @config_yaml_def = config
        @profile_configs = [DEFAULT_PROFILE_DEF] + config.profiles
        @profiles = [] of Defs::ProfileDef
        @resolved_profile = Defs::ProfileDef.new
        @user = User.new(user: config.user, github_access_token: github_access_token)
        load_profiles!
      else
        raise ConfigurationNotFoundError.new(Paths::CONFIG_YML)
      end
    end

    def save!
      config_yaml = @config_yaml_def.to_yaml
      File.write(Paths::CONFIG_YML, config_yaml, perm: 0o600)
    end

    private getter :github_access_token

    private def resolve_profile!
      resolved_profile.merge!(profiles)
    end
  end
end
