module MStrap
  class User
    @name : String
    @email : String
    @github : String
    @github_access_token : String?

    # Returns name of user
    getter :name

    # Returns email address of user
    getter :email

    # Returns GitHub user account
    getter :github

    def initialize(user : Defs::UserDef, github_access_token : String? = nil)
      @name = user.name.not_nil!
      @email = user.email.not_nil!
      @github = user.github.not_nil!
      @github_access_token = github_access_token
    end

    def initialize(@name, @email, @github, @github_access_token)
    end

    # Returns GitHub access token. Used by `strap.sh` to clone personal dotfiles
    # and Brewfile repositories. Loaded from `hub` command's config.
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
