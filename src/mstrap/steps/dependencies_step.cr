module MStrap
  module Steps
    class DependenciesStep < Step
      include Utils::Logging
      include Utils::System

      def self.requires_mstrap?
        false
      end

      def bootstrap
        set_strap_env!
        setup_hub_config
        strap_sh
        brew_bundle
      end

      private def github
        options[:github].as(String)
      end

      private def github_access_token
        (options[:github_access_token] ||= begin
          if File.exists?(hub_config_path)
            hub_config = File.open(hub_config_path) { |file| YAML.parse(file) }
            if hub_config["github.com"]? && hub_config["github.com"].as_a.any?
              hub_config["github.com"][0]["oauth_token"].as_s?
            else
              nil
            end
          end
        end).as(String?)
      end

      private def set_strap_env!
        ENV["STRAP_GIT_NAME"]     = options[:name].as(String)
        ENV["STRAP_GIT_EMAIL"]    = options[:email].as(String)
        ENV["STRAP_GITHUB_USER"]  = github
        ENV["STRAP_GITHUB_TOKEN"] = github_access_token
      end

      private def setup_hub_config
        if github_access_token && !File.exists?(hub_config_path)
          FileUtils.mkdir_p(config_path)
          contents = Templates::HubYml.new(github: github, github_access_token: github_access_token).to_s
          File.write(hub_config_path, contents, perm: 0o600)
        end
      end

      private def config_path
        @config_path ||= "#{ENV["HOME"]}/.config"
      end

      private def hub_config_path
        @hub_config_path ||= "#{config_path}/hub"
      end

      private def strap_sh
        logn "==> Running strap.sh: "
        unless cmd "sh #{MStrap::Paths::STRAP_SH_PATH} #{debug? ? "--debug" : ""}"
          logc "Uhh oh, something went wrong in strap.sh-land. Check above or in #{MStrap::Paths::LOG_FILE}."
        end
        success "Schweet. strap.sh said 'All Good'"
      end

      private def brew_bundle
        log "---> Installing dependencies from Brewfile (may take a while): "
        unless cmd "brew bundle --file=#{MStrap::Paths::BREWFILE} #{debug? ? "--verbose" : ""}"
          logc "Uhh oh, something went wrong in homebrewland. Check above or in #{MStrap::Paths::LOG_FILE}."
        end
        success "OK"
      end
    end
  end
end
