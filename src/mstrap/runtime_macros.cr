module MStrap
  # Defines utilities for working with language runtimes
  macro define_language_runtime(language_name, plugin_name)
    # Name of the language as a string. Always lowercase.
    def language_name
      "{{language_name.id.downcase}}"
    end

    def asdf_exec(command : String, args : Array(String), runtime_version : String? = nil)
      if runtime_version
        env = { "ASDF_{{plugin_name.id.upcase}}_VERSION" => runtime_version }
        cmd env, command, args, quiet: true
      else
        cmd command, args, quiet: true
      end
    end

    # Name of the ASDF plugin
    def asdf_plugin_name
      "{{plugin_name.id}}"
    end

    # Installs asdf plugin for {{language_name.id.capitalize}} and installs any {{language_name.id.capitalize}}
    # dependencies for the project.
    def setup
      cmd "asdf plugin-add {{plugin_name.id}}" unless has_asdf_plugin?

      with_dir_version(Dir.current) do
        cmd "asdf install {{plugin_name.id}} #{current_version}"
        bootstrap
      end
    end

    # Returns the version of {{language_name.id.capitalize}} used by the current
    # directory or specified by the environment.
    #
    # NOTE: This will not traverse parent directories to find versions files.
    def current_version
      version_path = File.join(Dir.current, ".{{language_name.id}}-version")
      version = if File.exists?(version_path)
        File.read(version_path).strip
      else
        ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"]?
      end
    end

    # Executes the block's context using the given directory's {{language_name.id.capitalize}}
    # version or the version specified by the environment.
    #
    # NOTE: This will not traverse parent directories to find versions files.
    def with_dir_version(dir)
      env_version = ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"]?
      begin
        Dir.cd(dir) do
          ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"] = current_version
          yield
        end
      ensure
        ENV["ASDF_{{plugin_name.id.upcase}}_VERSION"] = env_version
      end
    end

    # Returns whether the ASDF plugin has been installed for {{language_name.id.capitalize}} or not
    def has_asdf_plugin?
      `asdf plugin-list`.chomp.split("\n").includes?("{{plugin_name.id}}")
    end

    # Returns whether any versions of {{language_name.id.capitalize}} have been
    # installed by ASDF.
    def has_versions?
      installed_versions.any?
    end

    # Returns a list of the versions of {{language_name.id.capitalize}} installed
    # by ASDF.
    def installed_versions
      `asdf list {{plugin_name.id}} 2>&1`.
        chomp.
        split("\n").
        map(&.strip).
        reject do |version|
          version.blank? || version == "No versions installed"
        end
    end
  end
end
