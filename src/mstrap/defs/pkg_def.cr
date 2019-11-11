module MStrap
  module Defs
    class PkgDef < Def
      YAML.mapping(
        name: String,
        version: String?
      )

      def merge!(other : self)
        if other.version
          self.version = other.version
        end
      end
    end
  end
end
