module MStrap
  module Defs
    class ProjectDef < Def
      DEFAULT_RUN_SCRIPTS = true
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
        runtimes: {
          type: Array(String),
          nilable: false,
          default: [] of String,
          presence: true
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
        @runtimes = [] of String
        @websocket = DEFAULT_WEBSOCKET
        @web = DEFAULT_WEB
      end

      def merge!(other : self)
        self.name = other.name
        self.hostname = other.hostname if other.hostname_present?
        self.path = other.path if other.path_present?
        self.port = other.port if other.port_present?
        self.repo = other.repo
        self.run_scripts = other.run_scripts
        self.runtimes = other.runtimes if other.runtimes_present?
        self.upstream = other.upstream if other.upstream_present?
        self.websocket = other.websocket
        self.web = other.web if other.web_present?
      end
    end
  end
end
