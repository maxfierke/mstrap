module MStrap
  abstract class Step
    # BUG?: Why aren't these inferred correctly?
    @options : CLIOptions
    @profile : Defs::ProfileDef
    @user : User

    getter :config
    getter :options
    getter :profile
    getter :user

    def initialize(config : Configuration)
      @config = config
      @options = config.cli
      @profile = config.profile
      @user = config.user
    end

    abstract def bootstrap

    def self.requires_mstrap?
      true
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
