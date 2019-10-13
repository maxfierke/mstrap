module MStrap
  class Configuration
    @cli : CLIOptions
    @profile_configs : Array(Defs::ProfileConfigDef)
    @profiles : Array(Defs::ProfileDef)
    @resolved_profile : Defs::ProfileDef
    @user : User

    getter :cli, :profile_configs, :profiles, :resolved_profile, :user

    def initialize(cli : CLIOptions, config : Defs::ConfigDef, github_access_token : String? = nil)
      @cli = cli
      @profile_configs = config.profiles
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
      if File.exists?(Paths::PROFILE_YML)
        profile_yaml = File.read(Paths::PROFILE_YML)
        profiles << Defs::ProfileDef.from_yaml(profile_yaml)
      end

      profile_configs.each do |profile_config|
        if profile_config.url
          ProfileFetcher.new(profile_config).fetch!
        end

        profile_yaml = File.read(profile_config.path.not_nil!)
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
