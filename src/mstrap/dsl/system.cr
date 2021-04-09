module MStrap
  module DSL
    module System
      # Executes a given command and waits for it to complete, returning whether
      # the exit status indicated success.
      #
      # By default the process is configured with input, output, and error of
      # the `mstrap` process.
      #
      # * _env_: optionally specifies the environment for the command
      # * _command_: specifies the command to run. Arguments are allowed here, if
      #   _args_ are omitted and will be evaluated by the system shell.
      # * _args_: optionally specifies arguments for the command. These will not
      #   be processed by the shell.
      # * _shell_: specifies whether to run the command through the system shell
      # * _input_: specifies
      # * _quiet_: If passed as `true`, it does no logging. If `mstrap` is
      #   running in debug mode, process output is always logged.
      def cmd(
        env : Hash?,
        command : String,
        args : Array(String)?,
        shell = true,
        input = Process::Redirect::Inherit,
        output = Process::Redirect::Inherit,
        error = Process::Redirect::Inherit,
        quiet = false,
        sudo = false
      )
        if sudo
          if args
            args.unshift(command)
            command = "sudo"
          else
            command = "sudo #{command}"
          end
        end

        logd "+ #{env ? env : ""} #{command} #{args ? args.join(" ") : ""}"

        named = {
          shell:  shell,
          env:    env,
          input:  input,
          output: output,
          error:  error,
        }

        if MStrap.debug?
          named = named.merge({
            input:  Process::Redirect::Inherit,
            output: Process::Redirect::Inherit,
            error:  Process::Redirect::Inherit,
          })
        elsif quiet
          named = named.merge({
            input:  Process::Redirect::Close,
            output: Process::Redirect::Close,
            error:  Process::Redirect::Close,
          })
        end

        child = Process.new(command, args, **named)

        at_exit {
          # Cleanup this process when we exit, if it's still running. (e.g. receiving SIGINT)
          unless child.terminated?
            # Reap the whole process group, otherwise nested processes may live
            # to print output another day
            pgid = Process.pgid(child.pid)
            Process.signal(Signal::TERM, -pgid)
            child.wait
          end
        }

        status = child.wait
        status.success?
      end

      # :nodoc:
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

      # :ditto:
      def cmd(command, *args, **kwargs)
        cmd(nil, command, *args, **kwargs)
      end
    end
  end
end
