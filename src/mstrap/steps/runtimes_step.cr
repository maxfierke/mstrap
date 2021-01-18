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
        MStrap::Runtime.all.each do |runtime|
          if runtime.has_asdf_plugin? && runtime.has_versions?
            logn "==> Setting global #{runtime.language_name} settings"
            set_default_to_latest(runtime)
            packages = runtime_packages(runtime)

            if packages.any?
              install_package_globals(runtime, packages)
            end
          end
        end
      end

      private def runtime_config(runtime)
        profile.runtimes.find { |r| r.name == runtime.language_name }
      end

      private def runtime_packages(runtime)
        cfg = runtime_config(runtime)
        if cfg
          cfg.packages
        else
          [] of Defs::PkgDef
        end
      end

      private def set_default_to_latest(runtime)
        cfg = runtime_config(runtime)

        latest_version = if cfg && cfg.default_version
                           cfg.default_version
                         else
                           runtime.installed_versions.last
                         end

        log "--> Setting default #{runtime.language_name} version to #{latest_version}: "
        unless cmd "asdf global #{runtime.asdf_plugin_name} #{latest_version}", quiet: true
          logc "Could not set global #{runtime.language_name} version to #{latest_version}"
        end
        success "OK"
      end

      private def install_package_globals(runtime, packages)
        logn "--> Installing global packages for installed #{runtime.language_name} versions: "
        runtime.installed_versions.each do |version|
          package_names = packages.map(&.name)
          log "Installing #{package_names.join(", ")} for #{runtime.language_name} #{version}: "
          unless runtime.install_packages(packages, version)
            logc "Could not install global #{runtime.language_name} packages for #{version}"
          end
          success "OK"
        end
      end
    end
  end
end
