module MStrap
  module Defs
    class PkgDef < Def
      @[HCL::Label]
      property name : String

      @[HCL::Attribute]
      property version : String?

      def_equals_and_hash @name, @version

      def initialize(@name, @version = nil)
      end

      def merge!(other : self)
        if other.version
          self.version = other.version
        end
      end
    end
  end
end
