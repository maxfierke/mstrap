module MStrap
  module Steps
    # Runnable as `mstrap dependencies`, the Dependencies step runs [`strap.sh`](https://github.com/MikeMcQuaid/strap/)
    # and installs software from any available `Brewfile`s.
    class DependenciesStep < Step
      include Utils::Env
      include Utils::Logging
      include Utils::System

      def self.description
        "Basic machine bootstrapping with strap.sh, hub, and brew bundle."
      end

      def self.requires_mstrap?
        false
      end

      def self.requires_shell_restart?
        true
      end

      def bootstrap
        set_strap_env!
        setup_hub_config
        strap_sh
        load_profile!
        brew_bundle
      end

      private def set_strap_env!
        ENV["STRAP_GIT_NAME"] = user.name
        ENV["STRAP_GIT_EMAIL"] = user.email
        ENV["STRAP_GITHUB_USER"] = user.github
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
        logn "==> Running strap.sh"
        unless cmd "bash #{MStrap::Paths::STRAP_SH_PATH} #{debug? ? "--debug" : ""}"
          logc "Uhh oh, something went wrong in strap.sh-land. Check above or in #{MStrap::Paths::LOG_FILE}."
        end
        success "Finished running strap.sh"
        set_brew_env_if_not_set
      end

      private def brew_bundle
        logn "==> Installing dependencies from Brewfile (may take a while): "

        config.profile_configs.each do |profile_config|
          brewfile_path = File.join(profile_config.dir, "Brewfile")

          if File.exists?(brewfile_path)
            log "--> Installing dependencies from Brewfile from profile '#{profile_config.name})': "
            unless cmd "brew bundle --file=#{brewfile_path} #{debug? ? "--verbose" : ""}"
              logc "Uhh oh, something went wrong in homebrewland. Check above or in #{MStrap::Paths::LOG_FILE}."
            end
            success "OK"
          end
        end
      end

      private def load_profile!
        log "--> Reloading profile: "
        config.reload!
        success "OK"
      end

      private def set_brew_env_if_not_set
        {% if flag?(:linux) %}
          # Needed on initial run to continue
          unless cmd("brew --version", quiet: true)
            ENV["HOMEBREW_PREFIX"] = MStrap::Paths::HOMEBREW_PREFIX
            ENV["HOMEBREW_CELLAR"] = "#{MStrap::Paths::HOMEBREW_PREFIX}/Cellar"
            ENV["HOMEBREW_REPOSITORY"] = "#{MStrap::Paths::HOMEBREW_PREFIX}/Homebrew"
            path = ENV["PATH"]
            ENV["PATH"] = "#{MStrap::Paths::HOMEBREW_PREFIX}/bin:#{MStrap::Paths::HOMEBREW_PREFIX}/sbin:#{path}"
          end
        {% end %}
      end
    end
  end
end
