module MStrap
  abstract class Step
    include DSL

    @args : Array(String)
    @docker : Docker? = nil
    # BUG?: Why aren't these inferred correctly?
    @profile : Defs::ProfileDef
    @runtime_manager : RuntimeManager
    @user : User

    # Extra arguments passed to the step not processed by the main CLI
    getter :args

    # Loaded configuration for mstrap
    getter :config

    # Options passed from the CLI
    getter :options

    # Resolved profile for mstrap
    getter :profile

    # Language runtime manager for mstrap
    getter :runtime_manager

    # User configured for mstrap
    getter :user

    # Initializes the step. Called by `MStrap::Bootsrapper`. Typically not
    # called directly.
    def initialize(config : Configuration, cli_options : CLIOptions, args = [] of String)
      @args = args
      @config = config
      @options = cli_options
      @profile = config.resolved_profile
      @runtime_manager = config.runtime_manager
      @user = config.user
    end

    # Executes the step
    abstract def bootstrap

    # Short description of the step. Leveraged by the CLI help system.
    def self.description
      raise "Must specify in sub-class"
    end

    def self.long_description
      description
    end

    # Whether the step requires the mstrap environment to be loaded (`env.sh`)
    def self.requires_mstrap?
      true
    end

    # Whether the step requires the shell to be restarted after being run
    def self.requires_shell_restart?
      false
    end

    # Hook that can be implemented to modify CLI command flags or subcommands.
    def self.setup_cmd!(cmd : Commander::Command)
    end

    # Returns a `Docker` object that can be used to interact with and query
    # Docker.
    protected def docker
      @docker ||= Docker.new
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
