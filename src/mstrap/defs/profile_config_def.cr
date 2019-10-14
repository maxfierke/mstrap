module MStrap
  module Defs
    class ProfileConfigDef < Def
      YAML.mapping(
        name: {
          type: String,
          nilable: false
        },
        revision: {
          type: String,
          nilable: true,
          default: nil
        },
        url: {
          type: String,
          nilable: false
        }
      )

      def initialize(@name, @url, @revision = nil)
      end

      def merge!(other : self)
        self.name = other.name
        self.path = other.path if other.path
        self.revision = other.revision if other.revision
        self.url = other.url if other.url
      end

      def dir
        @dir ||= File.join(Paths::PROFILES_DIR, name)
      end

      def path
        @path ||= File.join(dir, "profile.yml")
      end
    end
  end
end
