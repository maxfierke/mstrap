module MStrap
  class User
    @name : String
    @email : String
    @github : String
    @github_access_token : String?

    getter :name, :email, :github

    def initialize(@name, @email, @github, @github_access_token)
    end

    def github_access_token
      @github_access_token ||= begin
        if File.exists?(Paths::HUB_CONFIG_XML)
          hub_config = File.open(Paths::HUB_CONFIG_XML) { |file| YAML.parse(file) }
          if hub_config["github.com"]? && hub_config["github.com"].as_a.any?
            hub_config["github.com"][0]["oauth_token"].as_s?
          else
            nil
          end
        end
      end
    end
  end
end
