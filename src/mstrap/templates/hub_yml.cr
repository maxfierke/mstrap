module MStrap
  module Templates
    class HubYml
      getter :github, :github_access_token

      def initialize(@github : String, @github_access_token : String?)
      end

      ECR.def_to_s "#{__DIR__}/hub.yml.ecr"
    end
  end
end
