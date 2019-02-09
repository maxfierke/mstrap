module MStrap
  module Steps
    class ShellStep < Step
      include Utils::Env
      include Utils::Logging

      SHELL_LINE = <<-BASH
      [ -f $HOME/.mstrap/env.sh ] && source $HOME/.mstrap/env.sh
      BASH
      SUPPORTED_SHELL_MSG = <<-MSG
      mstrap installed a shell script that needs to be loaded before you can
      continue bootstrapping.

      Either restart your current shell or `source ~/.mstrap/env.sh` to load the
      needed environment to continue.
      MSG
      UNSUPPORTED_SHELL_MSG = <<-MSG
      Think you're cooler than us, huh?

      mstrap couldn't detect a supported shell, so you're on your own here.

      Using the the runtime configuration of whatever your shell is, make sure that it
      is doing the equivalent of `source ~/.mstrap/env.sh` when the shell is initialized.
      MSG

      getter :name, :email, :github

      def self.bootstrap(options)
        new(options).bootstrap
      end

      def self.requires_mstrap?
        false
      end

      def initialize(@options : CLIOptions)
        super
        @name     = options[:name].as(String)
        @email    = options[:email].as(String)
        @github   = options[:github].as(String)
      end

      def bootstrap
        Dir.mkdir_p(MStrap::Paths::RC_DIR)

        contents = EnvSh.new(name, email, github).to_s
        File.write(env_sh_path, contents, perm: 0o600)

        unless mstrapped?
          if supported_shell?
            `touch #{shell_file_path} && echo '#{SHELL_LINE}' >> #{shell_file_path}`
            logn SUPPORTED_SHELL_MSG
          else
            logn UNSUPPORTED_SHELL_MSG
          end
          exit
        end
      end

      private def shell_file_path
        @shell_file_path ||= File.join(ENV["HOME"], shell_file)
      end

      private def shell_file
        @shell_file ||= if `#{ENV["SHELL"]} -c 'echo $ZSH_VERSION'`.strip != ""
          ".zshrc"
        elsif `#{ENV["SHELL"]} -c 'echo $BASH_VERSION'`.strip != ""
          ".bash_profile"
        else
          "wtf"
        end
      end

      private def supported_shell?
        shell_file != "wtf"
      end

      private def env_sh_path
        @env_sh_path ||= File.join(MStrap::Paths::RC_DIR, "env.sh")
      end
    end
  end
end