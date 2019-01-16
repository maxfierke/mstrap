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
        logd "+ #{env ? env : ""}#{args.join(" ")}"

        status = Process.run(
          command,
          args.to_a,
          shell: shell,
          env: env,
          input: input,
          output: output,
          error: error
        )
        status.success?
      end

      def cmd(command, *args, **kwargs)
        cmd(nil, command, *args, **kwargs)
      end
    end
  end
end
