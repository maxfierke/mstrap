module MStrap
  # :nodoc:
  module Templates
    class HubYml
      getter :github, :github_access_token

      def initialize(@github : String, @github_access_token : String?)
      end

      ECR.def_to_s "#{__DIR__}/hub.yml.ecr"

      def write_to_config!
        FileUtils.mkdir_p(Paths::XDG_CONFIG_DIR)
        File.write(Paths::HUB_CONFIG_XML, to_s, perm: 0o600)
      end
    end
  end
end
