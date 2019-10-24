module MStrap
  abstract class Step
    @args : Array(String)
    # BUG?: Why aren't these inferred correctly?
    @options : CLIOptions
    @profile : Defs::ProfileDef
    @user : User

    # Extra arguments passed to the step not processed by the main CLI
    getter :args

    # Loaded configuration for mstrap
    getter :config

    # Options passed from the CLI
    getter :options

    # Resolved profile for mstrap
    getter :profile

    # User configured for mstrap
    getter :user

    # Initializes the step. Called by `MStrap::Bootsrapper`. Typically not
    # called directly.
    def initialize(config : Configuration, args = [] of String)
      @args = args
      @config = config
      @options = config.cli
      @profile = config.resolved_profile
      @user = config.user
    end

    # Executes the step
    abstract def bootstrap

    # Short description of the step. Leveraged by the CLI help system.
    def self.description
      raise "Must specify in sub-class"
    end

    # Whether the step requires the mstrap environment to be loaded (`env.sh`)
    def self.requires_mstrap?
      true
    end

    # Whether the step requires the shell to be restarted after being run
    def self.requires_shell_restart?
      false
    end

    macro finished
      # :nodoc:
      def self.all
        @@step ||= {
          {% for subclass in @type.subclasses %}
            {% key = subclass.name.stringify.split("::").last.gsub(/Step$/, "").underscore.gsub(/_/, "-") %}
            "{{ key.id }}": {{ subclass.name }},
          {% end %}
        }
      end
    end
  end
end
