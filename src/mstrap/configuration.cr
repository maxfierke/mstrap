module MStrap
  class Configuration
    class ConfigurationLoadError < Exception; end

    @cli : CLIOptions
    @profile_configs : Array(Defs::ProfileConfigDef)
    @profiles : Array(Defs::ProfileDef)
    @resolved_profile : Defs::ProfileDef
    @user : User

    DEFAULT_PROFILE_DEF = Defs::ProfileConfigDef.new(
      name: "Default",
      path: Paths::PROFILE_YML
    )

    getter :cli, :profile_configs, :profiles, :resolved_profile, :user

    def initialize(cli : CLIOptions, config : Defs::ConfigDef, github_access_token : String? = nil)
      @cli = cli
      @profile_configs = [DEFAULT_PROFILE_DEF] + config.profiles
      @profiles = [] of Defs::ProfileDef
      @resolved_profile = Defs::ProfileDef.new
      @user = User.new(
        name: config.user.name.not_nil!,
        email: config.user.email.not_nil!,
        github: config.user.github.not_nil!,
        github_access_token: github_access_token
      )
    end

    def load_profiles!
      profile_configs.each do |profile_config|
        if profile_config.url
          ProfileFetcher.new(profile_config).fetch!
        elsif !profile_config.path
          raise ConfigurationLoadError.new(
            "#{profile_config.name}: A url or path must be specified"
          )
        end

        path = profile_config.path

        if !path || !File.exists?(path)
          next if profile_config == DEFAULT_PROFILE_DEF
          raise ConfigurationLoadError.new(
            "#{profile_config.name}: #{path} does not exist or is not accessible."
          )
        end

        profile_yaml = File.read(path)
        profiles << Defs::ProfileDef.from_yaml(profile_yaml)
      end

      resolve_profile!

      self
    end

    private def resolve_profile!
      # TODO: cleanup this godawful merging code
      profiles.each do |p|
        p.projects.each do |proj|
          unless resolved_profile.projects.any? { |pr| pr.cname == proj.cname }
            resolved_profile.projects << proj
          end
        end

        p.package_globals.gems.each do |gem|
          unless resolved_profile.package_globals.gems.any? { |g| g.name == gem.name }
            resolved_profile.package_globals.gems << gem
          end
        end

        p.package_globals.npm.each do |pkg|
          unless resolved_profile.package_globals.npm.any? { |n| n.name == pkg.name }
            resolved_profile.package_globals.npm << pkg
          end
        end

        p.package_globals.pip.each do |pkg|
          unless resolved_profile.package_globals.pip.any? { |pi| pi.name == pkg.name }
            resolved_profile.package_globals.pip << pkg
          end
        end
      end
    end
  end
end
