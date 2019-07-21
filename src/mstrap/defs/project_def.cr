module MStrap
  module Defs
    class ProjectDef
      DEFAULT_RUN_SCRIPTS = true
      DEFAULT_RUNTIME = "unknown"
      DEFAULT_WEB = false
      DEFAULT_WEBSOCKET = false

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
          default: DEFAULT_RUN_SCRIPTS,
        },
        runtime: {
          type: String,
          nilable: false,
          default: DEFAULT_RUNTIME
        },
        upstream: {
          type: String?,
          presence: true
        },
        websocket: {
          type: Bool,
          nilable: false,
          default: DEFAULT_WEBSOCKET,
          presence: true
        },
        web: {
          type: Bool,
          nilable: false,
          default: DEFAULT_WEB,
          presence: true
        }
      )

      def initialize
        @name = ""
        @cname = ""
        @repo = ""
        @run_scripts = DEFAULT_RUN_SCRIPTS
        @runtime = DEFAULT_RUNTIME
        @websocket = DEFAULT_WEBSOCKET
        @web = DEFAULT_WEB
      end
    end
  end
end
