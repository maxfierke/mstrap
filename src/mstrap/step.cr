module MStrap
  abstract class Step
    getter :options

    def initialize(@options : CLIOptions)
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
