module MStrap
  module Defs
    class ConfigDef
      include HCL::Serializable

      @[HCL::Attribute]
      property version = "1.0"

      @[HCL::Block(key: "profile")]
      property profiles = [] of ::MStrap::Defs::ProfileConfigDef

      @[HCL::Block]
      property user = ::MStrap::Defs::UserDef.new

      def_equals_and_hash @version, @profiles, @user

      def self.from_url(url : String)
        HTTP::Client.get(url, tls: MStrap.tls_client) do |response|
          self.from_hcl(response.body_io.gets_to_end)
        end
      end

      def initialize(@user = UserDef.new, @profiles = Array(ProfileConfigDef).new)
      end
    end
  end
end
