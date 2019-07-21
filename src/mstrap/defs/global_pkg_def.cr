module MStrap
  module Defs
    class GlobalPkgDef
      YAML.mapping(
        gems: {
          type: Array(GemDef),
          nilable: false,
          default: [] of GemDef
        },
        npm: {
          type: Array(NpmPkgDef),
          nilable: false,
          default: [] of NpmPkgDef
        },
        pip: {
          type: Array(PipPkgDef),
          nilable: false,
          default: [] of PipPkgDef
        },
      )

      def initialize
        @gems = [] of GemDef
        @npm = [] of NpmPkgDef
        @pip = [] of PipPkgDef
      end
    end
  end
end
