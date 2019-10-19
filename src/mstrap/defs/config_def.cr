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
        },
        version: {
          type: String,
          nilable: false,
          default: "1.0"
        }
      )

      @version = "1.0"

      def self.from_url(url : String)
        HTTP::Client.get(url) do |response|
          self.from_yaml(response.body_io.gets_to_end)
        end
      end

      def initialize(@user = UserDef.new, @profiles = Array(ProfileConfigDef).new)
      end
    end
  end
end
