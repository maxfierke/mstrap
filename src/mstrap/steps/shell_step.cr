module MStrap
  module Steps
    # Runnable as `mstrap shell`, the Shell step is responsible for creating
    # the `env.sh` script and injecting it into the current shell's configuration.
    #
    # NOTE: Only `bash` and `zsh` are supported for automatic injection. Other
    # shells, such as `fish` or `tcsh`, will need to be configured manually.
    class ShellStep < Step
      # :nodoc:
      SHELL_LINE = <<-BASH
      [ -f $HOME/.mstrap/env.sh ] && source $HOME/.mstrap/env.sh
      BASH

      # :nodoc:
      SUPPORTED_SHELL_MSG = <<-MSG
      mstrap installed a shell script that needs to be loaded before you can
      continue bootstrapping.
      MSG

      # :nodoc:
      UNSUPPORTED_SHELL_MSG = <<-MSG
      mstrap couldn't detect a supported shell (bash or zsh).

      Using the the runtime configuration of whatever your shell is, make sure that it
      is doing the equivalent of `source ~/.mstrap/env.sh` when the shell is initialized.
      MSG

      @login_shell : String? = nil
      @shell_name : String? = nil

      def self.bootstrap(options)
        new(options).bootstrap
      end

      def self.description
        "Injects mstrap's env.sh into the running shell's config"
      end

      def self.requires_mstrap?
        false
      end

      def self.requires_shell_restart?
        true
      end

      def bootstrap
        Dir.mkdir_p(MStrap::Paths::RC_DIR)

        contents = Templates::EnvSh.new(shell_name, runtime_manager).to_s
        File.write(env_sh_path, contents, perm: 0o600)

        exit_if_shell_changed!

        unless MStrap.mstrapped? || shell_instrumented?
          if shell_supported?
            logn "==> Injecting magic shell scripts into your #{shell_file_name}: "
            `touch #{shell_file_path} && echo '#{SHELL_LINE}' >> #{shell_file_path}`
            success "OK"
            logw SUPPORTED_SHELL_MSG
            logn "==> Reloading mstrap with new shell config..."
            Process.exec(login_shell, ["-c", "source #{env_sh_path} && #{Process.executable_path}"])
          else
            log "==> Injecting magic shell scripts into your shell config: "
            logn "FAIL".colorize(:red)
            logw UNSUPPORTED_SHELL_MSG
            exit
          end
        end
      end

      private def shell_file_path
        @shell_file_path ||=
          if shell_file_name = self.shell_file_name
            File.join(ENV["HOME"], shell_file_name)
          end
      end

      private def shell_file_name
        @shell_file ||=
          if ENV["SHELL"]? && `#{ENV["SHELL"]} -c 'echo $ZSH_VERSION'`.strip != ""
            ".zshrc"
          elsif ENV["SHELL"]? && `#{ENV["SHELL"]} -c 'echo $BASH_VERSION'`.strip != ""
            ".bash_profile"
          end
      end

      private def shell_instrumented?
        if (path = shell_file_path) && File.exists?(path)
          File.read(path).includes?(SHELL_LINE)
        else
          false
        end
      end

      private def shell_name
        @shell_name ||= login_shell.split("/").last
      end

      private def shell_supported?
        !shell_file_name.nil?
      end

      private def env_sh_path
        @env_sh_path ||= File.join(MStrap::Paths::RC_DIR, "env.sh")
      end

      private def exit_if_shell_changed!
        if ENV["SHELL"] != login_shell
          logw "Your currently active shell is not the same as your login shell."
          logw "You may have changed your default login shell recently and should"
          logw "restart before continuing with mstrap."
          exit 1
        end
      end

      private def login_shell
        @login_shell ||= begin
          {% if flag?(:linux) %}
            `getent passwd #{ENV["USER"]} | cut -d: -f7`.chomp
          {% elsif flag?(:darwin) %}
            user_def = `dscl . -read /Users/#{ENV["USER"]} UserShell`
            user_def.gsub(/^UserShell: /, "").strip
          {% else %}
            # This is wrong, but ensures a no-op on unsupported platforms
            ENV["SHELL"]
          {% end %}
        end
      end
    end
  end
end
