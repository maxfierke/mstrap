module MStrap
  module Defs
    class ProfileDef
      YAML.mapping(
        package_globals: {
          type: GlobalPkgDef,
          nilable: false,
          default: GlobalPkgDef.new
        },
        projects: {
          type: Array(ProjectDef),
          nilable: false,
          default: [] of ProjectDef
        }
      )

      def initialize
        @package_globals = GlobalPkgDef.new
        @projects = [] of ProjectDef
      end
    end
  end
end
