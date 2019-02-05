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

        status = Process.run(
          command,
          args.size > 0 ? args.to_a : nil,
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
