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

      def initialize
        @name = nil
        @email = nil
        @github = nil
      end

      def initialize(@name, @email, @github)
      end
    end
  end
end
