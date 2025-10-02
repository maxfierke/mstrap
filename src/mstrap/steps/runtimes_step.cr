module MStrap
  module Steps
    # Runnable as `mstrap runtimes`, the runtimes step sets the default global
    # runtime versions to the latest installed and installs any global runtime
    # packages specified by any loaded profiles specified for the language
    # runtime.
    class RuntimesStep < Step
      def self.description
        "Sets default language runtime versions and installs global runtime packages"
      end

      def bootstrap
        runtimes.each_value do |runtime|
          if runtime.has_runtime_plugin? && runtime.has_versions?
            logn "==> Setting global #{runtime.language_name} settings"
            set_default_to_latest(runtime)
            packages = runtime_packages(runtime)

            if !packages.empty?
              install_package_globals(runtime, packages)
            end
          end
        end
      end

      private def runtime_config(runtime)
        profile.runtimes[runtime.language_name]?
      end

      private def runtime_packages(runtime)
        cfg = runtime_config(runtime)
        if cfg
          cfg.packages
        else
          Hash(String, Defs::PkgDef).new
        end
      end

      private def set_default_to_latest(runtime)
        cfg = runtime_config(runtime)

        latest_version =
          if cfg && cfg.default_version
            cfg.default_version
          else
            runtime.installed_versions.last
          end

        return unless latest_version

        log "--> Setting default #{runtime.language_name} version to #{latest_version}: "
        unless runtime.runtime_manager.set_global_version(runtime.language_name, latest_version)
          logc "Could not set global #{runtime.language_name} version to #{latest_version}"
        end
        success "OK"
      end

      private def install_package_globals(runtime, packages)
        logn "--> Installing global packages for installed #{runtime.language_name} versions: "
        runtime.installed_versions.each do |version|
          package_names = packages.keys
          log "Installing #{package_names.join(", ")} for #{runtime.language_name} #{version}: "
          unless runtime.install_packages(packages.values, version)
            logc "Could not install global #{runtime.language_name} packages for #{version}"
          end
          success "OK"
        end
      end
    end
  end
end
