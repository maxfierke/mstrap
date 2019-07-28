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
        load_profile!
      end

      private def set_strap_env!
        ENV["STRAP_GIT_NAME"]     = user.name
        ENV["STRAP_GIT_EMAIL"]    = user.email
        ENV["STRAP_GITHUB_USER"]  = user.github
        ENV["STRAP_GITHUB_TOKEN"] = user.github_access_token
      end

      private def setup_hub_config
        github_access_token = user.github_access_token

        if github_access_token && !File.exists?(Paths::HUB_CONFIG_XML)
          Templates::HubYml.new(
            github: user.github,
            github_access_token: github_access_token
          ).write_to_config!
        end
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

      private def load_profile!
        log "---> Reloading profile: "
        config.load_profile!
        success "OK"
      end
    end
  end
end
