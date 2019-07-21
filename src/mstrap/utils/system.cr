module MStrap
  module Utils
    module System
      include Env
      include Logging

      def cmd(
        env : Hash?,
        command : String,
        *args,
        shell = true,
        input = Process::Redirect::Inherit,
        output = Process::Redirect::Inherit,
        error = Process::Redirect::Inherit
      )
        logd "+ #{env ? env : ""} #{command} #{args.join(" ")}"

        child = Process.new(
          command,
          args.size > 0 ? args.to_a : nil,
          shell: shell,
          env: env,
          input: input,
          output: output,
          error: error
        )

        at_exit {
          # Cleanup this process when we exit, if it's still running. (e.g. receiving SIGINT)
          unless !child || child.terminated?
            child.kill
          end
        }

        status = child.wait
        status.success?
      end

      def cmd(command, *args, **kwargs)
        cmd(nil, command, *args, **kwargs)
      end
    end
  end
end
