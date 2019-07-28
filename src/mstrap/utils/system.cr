module MStrap
  module Utils
    module System
      include Env
      include Logging

      def cmd(
        env : Hash?,
        command : String,
        args : Array(String)?,
        shell = true,
        input = Process::Redirect::Inherit,
        output = Process::Redirect::Inherit,
        error = Process::Redirect::Inherit,
        quiet = false
      )
        logd "+ #{env ? env : ""} #{command} #{args ? args.join(" ") : ""}"

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

        child = Process.new(command, args, **named)

        at_exit {
          # Cleanup this process when we exit, if it's still running. (e.g. receiving SIGINT)
          unless !child || child.terminated?
            child.kill
          end
        }

        status = child.wait
        status.success?
      end

      def cmd(env : Hash?, command, *args, **kwargs)
        # TODO: I hate this
        command_args = if !args.empty?
          first_arg = args.first?
          if first_arg && first_arg.is_a?(Array(String))
            first_arg
          else
            arr_args = args.to_a

            if arr_args.is_a?(Array(NoReturn))
              nil
            else
              arr_args.as(Array(String))
            end
          end
        else
          nil
        end

        cmd(env, command, command_args, **kwargs)
      end

      def cmd(command, *args, **kwargs)
        cmd(nil, command, *args, **kwargs)
      end
    end
  end
end
