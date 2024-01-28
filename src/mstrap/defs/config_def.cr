module MStrap
  module Defs
    class ConfigDef
      include HCL::Serializable

      @[HCL::Attribute]
      property version = "1.1"

      @[HCL::Block(key: "profile")]
      property profiles = [] of ::MStrap::Defs::ProfileConfigDef

      @[HCL::Block]
      property runtimes = ::MStrap::Defs::RuntimesConfigDef.new

      @[HCL::Block]
      property user = ::MStrap::Defs::UserDef.new

      def_equals_and_hash @version, @profiles, @runtimes, @user

      def self.from_url(url : String)
        HTTP::Client.get(url, tls: MStrap.tls_client) do |response|
          self.from_hcl(response.body_io.gets_to_end)
        end
      end

      def initialize(
        @user = UserDef.new,
        @profiles = Array(ProfileConfigDef).new,
        @runtimes = RuntimesConfigDef.new
      )
      end
    end
  end
end
