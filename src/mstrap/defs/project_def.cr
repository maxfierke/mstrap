module MStrap
  module Defs
    class ProjectDef < Def
      @[HCL::Label]
      property cname : String = ""

      @[HCL::Attribute]
      property name : String = ""

      @[HCL::Attribute(presence: true)]
      property hostname : String? = nil

      @[HCL::Attribute(presence: true)]
      property path : String? = nil

      @[HCL::Attribute(presence: true)]
      property port : Int64? = nil

      @[HCL::Attribute]
      property repo : String = ""

      @[HCL::Attribute(presence: true)]
      property repo_upstream : String? = nil

      @[HCL::Attribute]
      property? run_scripts = true

      @[HCL::Attribute(presence: true)]
      property runtimes = [] of String

      @[HCL::Attribute(presence: true)]
      property upstream : String? = nil

      @[HCL::Attribute]
      property? websocket = false

      @[HCL::Attribute(presence: true)]
      property? web = false

      getter? hostname_present = false
      getter? path_present = false
      getter? port_present = false
      getter? repo_upstream_present = false
      getter? runtimes_present = false
      getter? upstream_present = false
      getter? web_present = false

      def_equals_and_hash @cname,
        @name,
        @hostname,
        @path,
        @port,
        @repo,
        @repo_upstream,
        @run_scripts,
        @runtimes,
        @upstream,
        @websocket,
        @web

      def initialize
      end

      def merge!(other : self)
        self.name = other.name
        self.hostname = other.hostname if other.hostname_present?
        self.path = other.path if other.path_present?
        self.port = other.port if other.port_present?
        self.repo = other.repo
        self.repo_upstream = other.repo_upstream if other.repo_upstream_present?
        self.run_scripts = other.run_scripts?
        self.runtimes = other.runtimes if other.runtimes_present?
        self.upstream = other.upstream if other.upstream_present?
        self.websocket = other.websocket?
        self.web = other.web? if other.web_present?
      end
    end
  end
end
