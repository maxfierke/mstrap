module MStrap
  module Steps
    # Runnable as `mstrap python`, the Python step sets the default global Python
    # version to the latest installed and installs any global pip packages
    # specified by any loaded profiles.
    class PythonStep < Step
      include Utils::Env
      include Utils::Logging
      include Utils::System

      @python_versions : Array(String)?
      @packages : Array(Defs::PipPkgDef)?

      def self.description
        "Set default global Python version and installs global pip packages"
      end

      def bootstrap
        return if !has_python? || python_versions.empty?
        logn "==> Bootstrapping Python"
        set_default_to_latest
        install_pip_globals
      end

      private def packages
        @packages ||= profile.package_globals.pip.not_nil!
      end

      private def set_default_to_latest
        latest_python = python_versions.last
        logn "---> Setting default Python version to latest: "
        log "Setting default Python version to #{latest_python}: "
        unless cmd "asdf global python #{latest_python}", quiet: true
          logc "Could not set global Python version to #{latest_python}"
        end
        success "OK"
      end

      private def install_pip_globals
        return if packages.empty?

        logn "---> Installing pip package globals for installed Python versions: "
        python_versions.each do |version|
          package_names = packages.map(&.name)
          log "Installing #{package_names.join(", ")} for Python #{version}: "
          pyenv_env = { "ASDF_PYTHON_VERSION" => version }
          pyenv_args = ["exec", "pip", "install", "-U"] + package_names
          unless cmd(pyenv_env, "asdf", pyenv_args, quiet: true)
            logc "Could not install global pip packages for #{version}"
          end
          success "OK"
        end
      end

      private def has_python?
        `asdf plugin-list`.chomp.split("\n").includes?("python")
      end

      private def python_versions
        @python_versions ||= `asdf list python 2>&1`.
          chomp.
          split("\n").
          map(&.strip).
          reject(&.blank?).
          not_nil!
      end
    end
  end
end
