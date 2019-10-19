module MStrap
  module Defs
    class PipPkgDef < Def
      YAML.mapping(
        name: String
      )

      def merge!(other : self)
        self.name = other.name
      end
    end
  end
end
