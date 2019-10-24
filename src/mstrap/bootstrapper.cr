module MStrap
  class Bootstrapper
    include Utils::Env
    include Utils::Logging

    # The default step run list. Running `mstrap` with no arguments
    # will run these steps in order.
    DEFAULT_STEPS = [
      :init,
      :dependencies,
      :shell,
      :services,
      :projects,
      :node,
      :python,
      :ruby,
    ]

    @options : CLIOptions
    @step : Symbol?

    def initialize(config : Configuration)
      @config = config
      @options = config.cli
    end

    def bootstrap
      tracker.identify

      if step_key = step
        args = ARGV.dup
        validate_step!(step_key)
        run_step!(step_key, args)
        tracker.track("Single Step Run: #{step_key}", { step: step_key.to_s })
        success "`mstrap #{step_key}` has completed successfully!"
        print_shell_reload_warning if Step.all[step_key].requires_shell_restart?
      else
        logw "Strap in!"
        DEFAULT_STEPS.each { |s| run_step!(s) }
        tracker.track("Full Run")
        success "mstrap has completed successfully!"
        print_shell_reload_warning
      end
    end

    private getter :config, :options

    private def config_path
      @config_path ||= options.config_path
    end

    private def step
      @step ||= if step_arg = ARGV.shift?
        Step.all.keys.find { |step| step.to_s == step_arg }
      else
        nil
      end
    end

    private def validate_step!(step)
      if !Step.all.has_key?(step)
        logc "Could not find a step called '#{step}'"
      elsif Step.all[step].requires_mstrap? && !mstrapped?
        logc "You must do a full mstrap run before you can run `mstrap #{step}`"
      end
    end

    private def run_step!(step, args = [] of String)
      Step.all[step].new(
        config,
        args: args
      ).bootstrap
    end

    private def tracker
      @tracker ||= MStrap::Tracker.for(options)
    end

    private def print_shell_reload_warning
      logw "Remember to restart your terminal, as the contents of your environment may have shifted."
    end
  end
end
