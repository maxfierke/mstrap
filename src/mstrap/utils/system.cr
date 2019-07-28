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
        error = Process::Redirect::Inherit,
        quiet = false
      )
        logd "+ #{env ? env : ""} #{command} #{args.join(" ")}"

        command_args = args.size > 0 ? args.to_a : nil
        named = {
          shell: shell,
          env: env,
          input: input,
          output: output,
          error: error
        }

        if debug?
          named = named.merge({
            input: Process::Redirect::Inherit,
            output: Process::Redirect::Inherit,
            error: Process::Redirect::Inherit
          })
        elsif quiet
          named = named.merge({
            input: Process::Redirect::Close,
            output: Process::Redirect::Close,
            error: Process::Redirect::Close
          })
        end

        child = Process.new(command, command_args, **named)

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
