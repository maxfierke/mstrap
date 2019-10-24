module MStrap
  # :nodoc:
  module Templates
    class EnvSh
      getter :name, :email, :github

      def initialize(@name : String, @email : String, @github : String)
      end

      ECR.def_to_s "#{__DIR__}/env.sh.ecr"
    end
  end
end
