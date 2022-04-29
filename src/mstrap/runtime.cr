module MStrap
  # Base class for working with language runtimes
  abstract class Runtime
    include DSL

    @asdf_version_env_var : String?

    # Execute a command using a specific language runtime version
    def asdf_exec(command : String, args : Array(String), runtime_version : String? = nil)
      if runtime_version
        env = {asdf_version_env_var => runtime_version}
        cmd env, command, args, quiet: true
      else
        cmd command, args, quiet: true
      end
    end

    def asdf_install_plugin
      log "--> Adding #{asdf_plugin_name} to asdf for #{language_name} support: "
      unless cmd("asdf plugin-add #{asdf_plugin_name}", quiet: true)
        logc "There was an error adding the #{asdf_plugin_name} to asdf. Check #{MStrap::Paths::LOG_FILE} or run again with --debug"
      end
      success "OK"
    end

    # Name of the ASDF plugin. Defaults to language_name
    def asdf_plugin_name : String
      language_name
    end

    # :nodoc:
    def asdf_version_env_var
      @asdf_version_env_var ||= "ASDF_#{asdf_plugin_name.upcase}_VERSION"
    end

    # :nodoc:
    def asdf_version_from_env
      ENV[asdf_version_env_var]?
    end

    # :nodoc:
    def asdf_version_from_tool_versions
      tool_versions_path = File.join(Dir.current, ".tool-versions")
      return nil unless File.exists?(tool_versions_path)

      tool_versions = File.read(tool_versions_path).strip
      if matches = tool_versions.match(/^#{asdf_plugin_name}\s+([^\s]+)$/m)
        matches[1].strip
      else
        nil
      end
    end

    # :nodoc:
    def asdf_version_from_legacy_version_file
      version_path = File.join(Dir.current, ".#{language_name}-version")
      return nil unless File.exists?(version_path)
      File.read(version_path).strip
    end

    # Bootstrap the current directory for the runtime
    abstract def bootstrap

    # Returns the version of the language runtime used by the current
    # directory or specified by the environment.
    #
    # NOTE: This will not traverse parent directories to find versions files.
    def current_version
      [
        asdf_version_from_env,
        asdf_version_from_tool_versions,
        asdf_version_from_legacy_version_file,
      ].find { |version| version }
    end

    # Returns whether the ASDF plugin has been installed for a language runtime
    # or not
    def has_asdf_plugin?
      `asdf plugin-list`.chomp.split("\n").includes?(asdf_plugin_name)
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
      `asdf list #{asdf_plugin_name} 2>&1`
        .chomp
        .split("\n")
        .map(&.strip)
        .reject do |version|
          version.blank? || version == "No versions installed"
        end
    end

    # Installs global packages for the runtime with an optional version
    # specification, and optional runtime version.
    #
    # NOTE: The version specification is dependent upon the underlying package
    # manager and is passed verbatim.
    abstract def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool

    # Name of the language as a string. Always lowercase.
    abstract def language_name : String

    # Returns whether the project uses the runtime
    abstract def matches? : Bool

    # Installs asdf plugin for the language runtime and installs any of the
    # language runtime dependencies for the project.
    def setup
      asdf_install_plugin unless has_asdf_plugin?

      with_dir_version(Dir.current) do
        if current_version && current_version != "" && !has_version?(current_version)
          log "--> Installing #{language_name} #{current_version} via asdf-#{asdf_plugin_name}: "
          unless cmd("asdf install #{asdf_plugin_name} #{current_version}", quiet: true)
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
    def with_dir_version(dir)
      env_version = ENV[asdf_version_env_var]?
      begin
        Dir.cd(dir) do
          ENV[asdf_version_env_var] = current_version
          yield
        end
      ensure
        ENV[asdf_version_env_var] = env_version
      end
    end

    macro finished
      # :nodoc:
      def self.all
        @@runtimes ||= [
          {% for subclass in @type.subclasses %}
            {{ subclass.name }}.new,
          {% end %}
        ]
      end
    end
  end
end
