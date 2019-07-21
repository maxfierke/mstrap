module MStrap
  module Defs
    class ProjectDef
      GENERIC_TYPE = "generic"

      YAML.mapping(
        name: String,
        cname: String,
        hostname: {
          type: String?,
          presence: true
        },
        path: {
          type: String?,
          presence: true
        },
        port: {
          type: Int32?,
          presence: true
        },
        repo: String,
        run_scripts: {
          type: Bool,
          nilable: false,
          default: true,
        },
        type: {
          type: String,
          nilable: false,
          default: GENERIC_TYPE
        },
        upstream: {
          type: String?,
          presence: true
        }
      )

      def initialize
        @name = ""
        @cname = ""
        @repo = ""
        @type = GENERIC_TYPE
        @run_scripts = true
      end
    end
  end
end
