module MStrap
  module RuntimeManagers
    class ASDF < RuntimeManager
      def name : String
        "asdf"
      end

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
        `asdf plugin-list`.chomp.split("\n").includes?(plugin_name(language_name))
      end

      def install_plugin(language_name : String) : Bool
        asdf_plugin_name = plugin_name(language_name)

        if asdf_plugin_name
          cmd("asdf plugin-add #{asdf_plugin_name}", quiet: true)
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

      def set_global_version(language_name, version : String) : Bool
        cmd "asdf global #{plugin_name(language_name)} #{version}", quiet: true
      end

      # :nodoc:
      def version_env_var(language_name) : String
        if asdf_plugin_name = plugin_name(language_name)
          "ASDF_#{asdf_plugin_name.upcase}_VERSION"
        else
          "ASDF_#{language_name.upcase}_VERSION"
        end
      end

      # :nodoc:
      def version_from_env(language_name)
        env_var_name = version_env_var(language_name)
        ENV[env_var_name]?
      end

      # :nodoc:
      def version_from_tool_versions(language_name)
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

      # :nodoc:
      def version_from_legacy_version_file(language_name)
        version_path = File.join(Dir.current, ".#{language_name}-version")
        return nil unless File.exists?(version_path)
        File.read(version_path).strip
      end
    end
  end
end
