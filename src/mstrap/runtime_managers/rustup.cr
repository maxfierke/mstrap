module MStrap
  module RuntimeManagers
    class Rustup < RuntimeManager
      def current_version(language_name : String) : String?
        current_toolchain = `rustup show active-toolchain`.chomp
        extract_rust_version_from_toolchain(current_toolchain)
      end

      # Execute a command using a specific language runtime version
      def runtime_exec(language_name : String, command : String, args : Array(String)? = nil, runtime_version : String? = nil)
        exec_args = [] of String
        exec_args << runtime_version if runtime_version

        cmd_args = ["run"] + exec_args + ["--", command]
        cmd_args += args if args

        if command && (!args || args.empty?)
          cmd "rustup #{cmd_args.join(' ')}", quiet: true
        else
          cmd "rustup", cmd_args, quiet: true
        end
      end

      # Returns whether the mise plugin has been installed for a language runtime
      # or not
      def has_plugin?(language_name : String) : Bool
        language_name == "rust"
      end

      def install_plugin(language_name : String) : Bool
        language_name == "rust"
      end

      def install_version(language_name : String, version : String) : Bool
        cmd("rustup toolchain install #{version}", quiet: true)
      end

      # Returns a list of the versions of the language runtime installed
      # by mise.
      def installed_versions(language_name : String) : Array(String)
        rust_versions_list = `rustup toolchain list`.chomp.split("\n").map do |version|
          extract_rust_version_from_toolchain(version)
        end

        rust_versions_list
      end

      # Rustup doesn't support querying this, but "stable" is _probably_ safe
      def latest_version(language_name : String) : String
        "stable"
      end

      # Rust is the only language managed by rustup, so this is always "rust"!
      def plugin_name(language_name : String) : String?
        "rust"
      end

      def set_version(language_name : String, version : String?) : Bool
        cmd "rustup override set #{version}", quiet: true
      end

      def set_global_version(language_name, version : String) : Bool
        cmd "rustup default #{version}", quiet: true
      end

      def shell_activation(shell_name : String) : String
        <<-SHELL
        # Activate rustup for Rust compiler version management
        export PATH="$HOME/.cargo/bin:$PATH"
        SHELL
      end

      def supported_languages : Array(String)
        %w(rust)
      end

      private def extract_rust_version_from_toolchain(rustup_toolchain : String)
        version, _, _ = rustup_toolchain.partition('-')
        version
      end
    end
  end
end
