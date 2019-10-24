module MStrap
  module Steps
    # Runnable as `mstrap ruby`, the Ruby step sets the default global Ruby
    # version to the latest installed and installs any global gems specified by
    # any loaded profiles.
    class RubyStep < Step
      include Utils::Env
      include Utils::Logging
      include Utils::System

      @ruby_versions : Array(String)?
      @gems : Array(Defs::GemDef)?

      def self.description
        "Set default global Ruby version and installs global Ruby gems"
      end

      def bootstrap
        return if ruby_versions.empty?
        logn "==> Bootstrapping Ruby"
        set_default_to_latest
        install_gem_globals
      end

      private def gems
        @gems ||= profile.package_globals.gems.not_nil!
      end

      private def set_default_to_latest
        latest_ruby = ruby_versions.last
        logn "---> Setting default Ruby version to latest: "
        log "Setting default Ruby version to #{latest_ruby}: "
        unless cmd "asdf global ruby #{latest_ruby}", quiet: true
          logc "Could not set global Ruby version to #{latest_ruby}"
        end
        success "OK"
      end

      private def install_gem_globals
        return if gems.empty?

        logn "---> Installing Ruby gem globals for installed Ruby versions: "
        ruby_versions.each do |version|
          gem_names = gems.map(&.name)
          log "Installing #{gem_names.join(", ")} for Ruby #{version}: "
          rbenv_env = { "ASDF_RUBY_VERSION" => version }
          rbenv_args = ["exec", "gem", "install"] + gem_names
          unless cmd(rbenv_env, "asdf", rbenv_args, quiet: true)
            logc "Could not install global Ruby gems for #{version}"
          end
          success "OK"
        end
      end

      private def ruby_versions
        @ruby_versions ||= `asdf list ruby 2>&1`.
          chomp.
          split("\n").
          map(&.strip).
          reject(&.blank?).
          not_nil!
      end
    end
  end
end
