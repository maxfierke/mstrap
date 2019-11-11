module MStrap
  module Defs
    class RuntimeDef < Def
      YAML.mapping(
        default_version: {
          type: String,
          nilable: true,
          default: nil
        },
        packages: {
          type: Array(PkgDef),
          nilable: false,
          default: [] of PkgDef
        }
      )

      def initialize
        @packages = [] of PkgDef
      end

      def merge!(other : self)
        if other.default_version
          self.default_version = other.default_version
        end

        other.packages.each do |pkg|
          if existing_pkg = self.packages.find { |g| g.name == pkg.name }
            existing_pkg.merge!(pkg)
          else
            self.packages << pkg
          end
        end
      end
    end
  end
end
