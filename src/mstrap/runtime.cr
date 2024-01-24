module MStrap
  # Base class for working with language runtimes
  abstract class Runtime
    include DSL

    getter :runtime_manager

    def initialize(@runtime_manager : RuntimeManager)
    end

    # Execute a command using a specific language runtime version
    def runtime_exec(command : String, args : Array(String), runtime_version : String? = nil)
      if runtime_version
        version_env_var = runtime_manager.version_env_var(language_name)
        env = {version_env_var => runtime_version}
        cmd env, command, args, quiet: true
      else
        cmd command, args, quiet: true
      end
    end

    # Bootstrap the current directory for the runtime
    abstract def bootstrap

    # Returns the version of the language runtime used by the current
    # directory or specified by the environment.
    #
    # NOTE: This will not traverse parent directories to find versions files.
    def current_version
      runtime_manager.current_version(language_name)
    end

    # Returns whether the ASDF plugin has been installed for a language runtime
    # or not
    def has_runtime_plugin?
      runtime_manager.has_plugin?(language_name)
    end

    def has_version?(version)
      installed_versions.includes?(version)
    end

    # Returns whether any versions of the language runtime have been
    # installed by ASDF.
    def has_versions?
      !installed_versions.empty?
    end

    # Returns a list of the versions of the language runtime installed
    # by ASDF.
    def installed_versions
      runtime_manager.installed_versions(language_name)
    end

    # Installs global packages for the runtime with an optional version
    # specification, and optional runtime version.
    #
    # NOTE: The version specification is dependent upon the underlying package
    # manager and is passed verbatim.
    abstract def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool

    # Name of the language as a string. Always lowercase.
    abstract def language_name : String

    # Returns the latest version available for the language runtime, according
    # to the runtime manager
    def latest_version
      runtime_manager.latest_version(language_name)
    end

    # Returns whether the project uses the runtime
    abstract def matches? : Bool

    # Installs asdf plugin for the language runtime and installs any of the
    # language runtime dependencies for the project.
    def setup
      unless runtime_manager.has_plugin?(language_name)
        log "--> Installing #{language_name} plugin to #{runtime_manager.name}: "
        unless runtime_manager.install_plugin(language_name)
          logc "There was an error adding the #{language_name} plugin to #{runtime_manager.name}. Check #{MStrap::Paths::LOG_FILE} or run again with --debug"
        end
        success "OK"
      end

      with_dir_version(Dir.current) do
        current_version = self.current_version

        if current_version && current_version != "" && !has_version?(current_version)
          log "--> Installing #{language_name} #{current_version} via #{runtime_manager.name}: "
          unless runtime_manager.install_version(language_name, current_version)
            logc "There was an error installing the #{language_name} via asdf. Check #{MStrap::Paths::LOG_FILE} or run again with --debug"
          end
          success "OK"
        end
        bootstrap
      end
    end

    # Executes the block's context using the given directory's language runtime
    # version or the version specified by the environment.
    #
    # NOTE: This will not traverse parent directories to find versions files.
    def with_dir_version(dir, &)
      version_env_var = runtime_manager.version_env_var(language_name)
      env_version = ENV[version_env_var]?
      begin
        Dir.cd(dir) do
          ENV[version_env_var] = current_version
          yield
        end
      ensure
        ENV[version_env_var] = env_version
      end
    end

    # :nodoc:
    protected def raise_setup_error!(message)
      raise RuntimeSetupError.new(language_name, message)
    end
  end
end
