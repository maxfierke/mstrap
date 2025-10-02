module MStrap
  module Defs
    class RuntimesConfigDef
      include HCL::Serializable

      @[HCL::Attribute]
      property default_manager = "asdf"

      @[HCL::Block(key: "runtime")]
      property runtimes = Hash(String, ::MStrap::Defs::RuntimeConfigDef).new

      def_equals_and_hash @default_manager, @runtimes

      def initialize
      end
    end
  end
end
