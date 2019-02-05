module MStrap
  class Bootstrapper
    include Utils::Logging

    DEFAULT_STEPS = [
      :update,
      :bootstrap,
      :config,
      :services,
      :projects,
      :elixir,
      :node,
      :python,
      :ruby,
      :migrations
    ]

    @step : Symbol?

    def initialize(options = MStrap::CLIOptions.new)
      @options = options
      @step_args = [] of String
    end

    def bootstrap
      #tracker.identify

      FileUtils.mkdir_p(MStrap::Paths::RC_DIR, 0o775)

      if step_key = step
        validate_step!(step_key)
        run_step!(step_key)
        #tracker.track("Single Step Run: #{step_key}", { step: step_key.to_s })
        success "`mstrap #{step_key}` has completed successfully!"
      else
        logw "Strap in!"
        DEFAULT_STEPS.each { |s| run_step!(s) }
        #tracker.track("Full Run")
        success "mstrap has completed successfully!"
      end

      logw "Remember to restart your terminal, as the contents of your environment may have shifted."
    end

    private getter :options, :step_args

    private def config_path
      @config_path ||= options[:config_path].as(String)
    end

    private def step
      @step ||= if step_arg = ARGV.shift?
        @step_args = ARGV.dup
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

    private def run_step!(step)
      Step.all[step].new(options.merge({
        :step_args => step_args
      })).bootstrap
    end

    private def tracker
      #@tracker ||= MStrap::Tracker.new(options)
    end
  end
end
