module MStrap
  module Defs
    class ProfileConfigDef
      YAML.mapping(
        name: {
          type: String,
          nilable: false
        },
        path: {
          type: String,
          nilable: true,
          default: nil
        },
        revision: {
          type: String,
          nilable: true,
          default: nil
        },
        url: {
          type: String,
          nilable: true,
          default: nil
        }
      )

      def initialize(@name = nil, @path = nil, @revision = nil, @url = nil)
      end
    end
  end
end
