module MStrap
  module RuntimeManagers
    class Mise < RuntimeManager
      def name : String
        "mise"
      end

      def current_version(language_name : String) : String?
        `mise current #{plugin_name(language_name)}`.chomp
      end

      # Execute a command using a specific language runtime version
      def runtime_exec(language_name : String, command : String, args : Array(String)? = nil, runtime_version : String? = nil)
        exec_args = [] of String

        if runtime_version
          exec_args << "#{plugin_name(language_name)}@#{runtime_version}"
        end

        cmd_args = ["exec"] + exec_args + ["--", command]
        cmd_args += args if args

        if command && (!args || args.empty?)
          cmd "mise #{cmd_args.join(' ')}", quiet: true
        else
          cmd "mise", cmd_args, quiet: true
        end
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
          installed.map(&.["version"].as_s)
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

      def set_version(language_name : String, version : String?) : Bool
        true
      end

      def set_global_version(language_name, version : String) : Bool
        cmd "mise use -g #{plugin_name(language_name)}@#{version}", quiet: true
      end

      def shell_activation(shell_name : String) : String
        <<-SHELL
        # Activate mise for language runtime version management
        if [ -x "#{MStrap::MiseInstaller::MISE_INSTALL_PATH}" ]; then
          export MISE_ASDF_COMPAT=1
          eval "$(#{MStrap::MiseInstaller::MISE_INSTALL_PATH} activate #{shell_name})"
          eval "$(#{MStrap::MiseInstaller::MISE_INSTALL_PATH} hook-env)"
        fi
        SHELL
      end
    end
  end
end
