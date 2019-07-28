module MStrap
  abstract class Step
    @args : Array(String)
    # BUG?: Why aren't these inferred correctly?
    @options : CLIOptions
    @profile : Defs::ProfileDef
    @user : User

    getter :args, :config, :options, :profile, :user

    def initialize(config : Configuration, args = [] of String)
      @args = args
      @config = config
      @options = config.cli
      @profile = config.profile
      @user = config.user
    end

    abstract def bootstrap

    def self.requires_mstrap?
      true
    end

    def self.requires_shell_restart?
      false
    end

    macro finished
      def self.all
        @@step ||= {
          {% for subclass in @type.subclasses %}
            {% key = subclass.name.stringify.split("::").last.gsub(/Step$/, "").underscore %}
            {{ key.id }}: {{ subclass.name }},
          {% end %}
        }
      end
    end
  end
end
