module MStrap
  module Defs
    class ProfileConfigDef < Def
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

      def merge!(other : self)
        self.name = other.name
        self.path = other.path if other.path
        self.revision = other.revision if other.revision
        self.url = other.url if other.url
      end
    end
  end
end
