module MStrap
  module Platform
    {% if flag?(:linux) %}
      extend ::MStrap::Linux
    {% elsif flag?(:darwin) %}
      extend ::MStrap::Darwin
    {% else %}
      {{ raise "Unsupported platform" }}
    {% end %}

    @@found_commands = Hash(String, String).new

    # Indicates whether the host platform has a given command available
    #
    # Lookups are cached by default, but cached info can be skipped by passing
    # `skip_cache: true`
    def self.has_command?(command_name : String, skip_cache : Bool = false) : Bool
      if (cmd_path = @@found_commands[command_name]?) && !skip_cache
        true
      elsif cmd_path = Process.find_executable(command_name)
        @@found_commands[command_name] = cmd_path
        true
      else
        @@found_commands.delete(command_name)
        false
      end
    end

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
    # * _input_: specifies where to direct STDIN on the spawned process
    # * _output_: specifies where to direct STDOUT on the spawned process
    # * _error_: specifies where to direct STDERR on the spawned process
    # * _quiet_: If passed as `true`, it does no logging. If `mstrap` is
    #   running in debug mode, process output is always logged.
    # * _sudo_: specifies whether to run the command with superuser privileges
    def self.run_command(
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

      Log.debug { "+ #{env ? env : ""} #{command} #{args ? args.join(" ") : ""}" }

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

      # TODO: Refactor this into something less hacky
      # (e.g. push to a Deque used by a Process.on_terminate handler or something)
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

    # Installs a list of packages using the platform's package manager
    def self.install_packages!(packages : Array(String))
      platform.install_packages!(packages)
    end

    # Installs a single package using the platform's package manager
    def self.install_package!(package_name : String)
      platform.install_packages!([package_name])
    end

    # Install a single package using the platform's package manager
    def self.package_installed?(package_name : String)
      platform.package_installed?(package_name)
    end
  end
end
