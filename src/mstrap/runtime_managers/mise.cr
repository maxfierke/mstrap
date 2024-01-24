module MStrap
  module RuntimeManagers
    class Mise < RuntimeManager
      def name : String
        "mise"
      end

      def current_version(language_name : String) : String?
        `mise current #{language_name}`.chomp
      end

      # Returns whether the mise plugin has been installed for a language runtime
      # or not
      def has_plugin?(language_name : String) : Bool
        `mise plugins ls --core --user`.chomp.split("\n").includes?(plugin_name(language_name))
      end

      def install_plugin(language_name : String) : Bool
        cmd("mise plugins install #{plugin_name(language_name)}", quiet: true)
      end

      def install_version(language_name : String, version : String) : Bool
        cmd("mise install #{plugin_name(language_name)} #{version}", quiet: true)
      end

      # Returns a list of the versions of the language runtime installed
      # by mise.
      def installed_versions(language_name : String) : Array(String)
        mise_json_output = `mise ls -i #{plugin_name(language_name)} --json`
        mise_installed = JSON.parse(mise_json_output)

        if installed = mise_installed.as_a?
          installed.map { |version| version["version"].as_s }
        else
          Array(String).new
        end
      end

      def latest_version(language_name : String) : String
        `mise latest #{plugin_name(language_name)}`.chomp
      end

      # Name of the mise plugin for a particular language
      def plugin_name(language_name : String) : String?
        language_name
      end

      def set_global_version(language_name, version : String) : Bool
        cmd "mise use -g #{plugin_name(language_name)}@#{version}", quiet: true
      end

      # :nodoc:
      def version_env_var(language_name) : String
        if mise_plugin_name = plugin_name(language_name)
          "MISE_#{mise_plugin_name.upcase}_VERSION"
        else
          "MISE_#{language_name.upcase}_VERSION"
        end
      end
    end
  end
end
