module MStrap
  module Defs
    class RuntimesConfigDef
      include HCL::Serializable

      @[HCL::Attribute]
      property default_manager = "asdf"

      def_equals_and_hash @default_manager

      def initialize
      end
    end
  end
end
