module MStrap
  class Configuration
    @cli : CLIOptions
    @profile : Defs::ProfileDef
    @user : User

    getter :cli, :profile, :user

    def initialize(@cli, @profile, @user)
    end
  end
end
