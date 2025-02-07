module MStrap
  module RuntimeManagers
    class ASDF < RuntimeManager
      def current_version(language_name : String) : String?
        [
          version_from_env(language_name),
          version_from_tool_versions(language_name),
          version_from_legacy_version_file(language_name),
        ].find { |version| version }
      end

      # Returns whether the ASDF plugin has been installed for a language runtime
      # or not
      def has_plugin?(language_name : String) : Bool
        `asdf plugin list`.chomp.split("\n").includes?(plugin_name(language_name))
      end

      def install_plugin(language_name : String) : Bool
        asdf_plugin_name = plugin_name(language_name)

        if asdf_plugin_name
          cmd("asdf plugin add #{asdf_plugin_name}", quiet: true)
        else
          logw "Unable to find an ASDF plugin for #{language_name}"
          false
        end
      end

      def install_version(language_name : String, version : String) : Bool
        cmd("asdf install #{plugin_name(language_name)} #{version}", quiet: true)
      end

      # Returns a list of the versions of the language runtime installed
      # by ASDF.
      def installed_versions(language_name : String) : Array(String)
        `asdf list #{plugin_name(language_name)} 2>&1`
          .chomp
          .split("\n")
          .map(&.strip.lstrip('*'))
          .reject do |version|
            version.blank? || version == "No versions installed"
          end
      end

      def latest_version(language_name : String) : String
        `asdf latest #{plugin_name(language_name)}`.chomp
      end

      # Name of the ASDF plugin for a particular language
      def plugin_name(language_name : String) : String?
        case language_name
        when "go"
          "golang"
        when "node"
          "nodejs"
        else
          language_name
        end
      end

      # Execute a command using a specific language runtime version
      def runtime_exec(language_name : String, command : String, args : Array(String)? = nil, runtime_version : String? = nil)
        if runtime_version
          version_env_var = version_env_var(language_name)
          env = {version_env_var => runtime_version}
          cmd env, command, args, quiet: true
        else
          cmd command, args, quiet: true
        end
      end

      def set_version(language_name : String, version : String?) : Bool
        version_env_var = version_env_var(language_name)
        ENV[version_env_var] = version
        true
      end

      def set_global_version(language_name, version : String) : Bool
        cmd "asdf set --home #{plugin_name(language_name)} #{version}", quiet: true
      end

      def shell_activation(shell_name : String) : String
        <<-SHELL
        # Activate asdf for language runtime version management
        if [ -d "$(brew --prefix asdf)" ]; then
          export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

          if [ ! -f "$HOME/.asdfrc" ]; then
            echo "legacy_version_file = yes\n" > "$HOME/.asdfrc"
          fi
        fi
        SHELL
      end

      def supported_languages : Array(String)
        %w(crystal go node php python ruby rust)
      end

      private def version_env_var(language_name) : String
        if asdf_plugin_name = plugin_name(language_name)
          "ASDF_#{asdf_plugin_name.upcase}_VERSION"
        else
          "ASDF_#{language_name.upcase}_VERSION"
        end
      end

      private def version_from_env(language_name)
        env_var_name = version_env_var(language_name)
        ENV[env_var_name]?
      end

      private def version_from_tool_versions(language_name)
        tool_versions_path = File.join(Dir.current, ".tool-versions")
        return nil unless File.exists?(tool_versions_path)

        tool_versions = File.read(tool_versions_path).strip
        asdf_plugin_name = plugin_name(language_name)
        if matches = tool_versions.match(/^#{asdf_plugin_name}\s+([^\s]+)$/m)
          matches[1].strip
        else
          nil
        end
      end

      private def version_from_legacy_version_file(language_name)
        version_path = File.join(Dir.current, ".#{language_name}-version")
        return nil unless File.exists?(version_path)
        File.read(version_path).strip
      end
    end
  end
end
