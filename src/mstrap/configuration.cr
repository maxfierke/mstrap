module MStrap
  class Configuration
    @cli : CLIOptions
    @profile : Defs::ProfileDef
    @user : User

    getter :cli, :user
    getter! :profile

    def initialize(cli : CLIOptions, user : User, profile = Defs::ProfileDef.new)
      @cli = cli
      @user = user
      @profile = profile
    end

    def load_profile!
      profile_yaml = File.read(cli.config_path)
      self.profile = Defs::ProfileDef.from_yaml(profile_yaml)
      self
    end

    private setter :profile
  end
end
