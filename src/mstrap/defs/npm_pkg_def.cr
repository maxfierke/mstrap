module MStrap
  module Defs
    class NpmPkgDef < Def
      YAML.mapping(
        name: String
      )

      def merge!(other : self)
        self.name = other.name
      end
    end
  end
end
