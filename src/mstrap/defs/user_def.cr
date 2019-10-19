module MStrap
  module Defs
    class UserDef
      YAML.mapping(
        name: String?,
        email: String?,
        github: String?
      )

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
