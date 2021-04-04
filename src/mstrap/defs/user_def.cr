module MStrap
  module Defs
    class UserDef
      include HCL::Serializable

      @[HCL::Attribute]
      property name : String? = nil

      @[HCL::Attribute]
      property email : String? = nil

      @[HCL::Attribute]
      property github : String? = nil

      def_equals_and_hash @name, @email, @github

      def initialize(@name = nil, @email = nil, @github = nil)
      end
    end
  end
end
