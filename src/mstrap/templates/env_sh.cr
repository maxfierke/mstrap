module MStrap
  class EnvSh
    getter :name, :email, :github

    def initialize(@name, @email, @github)
    end

    ECR.def_to_s "env.sh.ecr"
  end
end
