module MStrap
  module DSL
    module System
      # See `MStrap::Platform#has_command?`
      def has_command?(command_name : String, **kwargs) : Bool
        MStrap::Platform.has_command?(command_name, **kwargs)
      end

      # See `MStrap::Platform#run_command`
      def cmd(
        env : Hash?,
        command : String,
        args : Array(String)?,
        **kwargs,
      )
        MStrap::Platform.run_command(
          env,
          command,
          args,
          **kwargs
        )
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
