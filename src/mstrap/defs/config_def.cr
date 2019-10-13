module MStrap
  module Defs
    class ConfigDef
      YAML.mapping(
        user: {
          type: UserDef,
          nilable: false,
          default: UserDef.new
        },
        profiles: {
          type: Array(ProfileConfigDef),
          nilable: false,
          default: [] of ProfileConfigDef
        }
      )

      def initialize(@user = UserDef.new, @profiles = Array(ProfileConfigDef).new)
      end
    end
  end
end
