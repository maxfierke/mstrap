module MStrap
  module Steps
    # Runnable as `mstrap dependencies`, the Dependencies step runs [`strap.sh`](https://github.com/MikeMcQuaid/strap/)
    # and installs software from any available `Brewfile`s.
    class DependenciesStep < Step
      def self.description
        "Basic machine bootstrapping with strap.sh, brew bundle, and other dependencies"
      end

      def self.requires_mstrap?
        false
      end

      def self.requires_shell_restart?
        true
      end

      def bootstrap
        install_mise if runtime_managers.any? { |rm| rm.name == "mise" }
        install_rustup if runtime_managers.any? { |rm| rm.name == "rustup" }
        set_strap_env!
        strap_sh
        load_profile!
        brew_bundle
      end

      private def set_strap_env!
        ENV["STRAP_GIT_NAME"] = user.name
        ENV["STRAP_GIT_EMAIL"] = user.email
        ENV["STRAP_GITHUB_USER"] = user.github
      end

      private def strap_sh
        logn "==> Running strap.sh"
        unless cmd "bash #{MStrap::Paths::STRAP_SH_PATH} #{MStrap.verbose? ? "--debug" : ""}"
          logc "Uhh oh, something went wrong in strap.sh-land."
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
            unless cmd "brew bundle --file=#{brewfile_path} #{MStrap.verbose? ? "--verbose" : ""}"
              logc "Uhh oh, something went wrong in homebrewland."
            end
            success "OK"
          end
        end
      end

      def install_mise
        mise_installer = MiseInstaller.new

        log "==> Checking for mise: "
        if mise_installer.installed? && !options.force?
          success "OK"
        else
          logn "Not installed".colorize(:yellow)
          log "--> Installing mise for language runtime version management: "
          mise_installer.install!
          success "OK"
        end
      end

      def install_rustup
        rustup_installer = RustupInstaller.new

        log "==> Checking for rustup: "
        if rustup_installer.installed? && !options.force?
          success "OK"
        else
          logn "Not installed".colorize(:yellow)
          log "--> Installing rustup for language runtime version management: "
          rustup_installer.install!
          success "OK"
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
