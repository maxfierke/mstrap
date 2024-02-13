module MStrap
  module Defs
    class RuntimeConfigDef
      include HCL::Serializable

      @[HCL::Label]
      property name : String

      @[HCL::Attribute]
      property manager : String? = nil

      def_equals_and_hash @name, @manager
    end
  end
end
