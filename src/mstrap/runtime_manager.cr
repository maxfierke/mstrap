module MStrap
  abstract class RuntimeManager
    include DSL

    def name : String
      {{ @type.name.stringify.split("::").last.downcase }}
    end

    def self.for(runtime_manager_name : String)
      if manager = all[runtime_manager_name]?
        manager
      else
        raise InvalidRuntimeManagerError.new(runtime_manager_name)
      end
    end

    abstract def current_version(language_name : String) : String?

    def has_plugin?(language_name : String) : Bool
      false
    end

    abstract def install_plugin(language_name : String) : Bool
    abstract def install_version(language_name : String, version : String) : Bool
    abstract def installed_versions(language_name : String) : Array(String)
    abstract def latest_version(language_name : String) : String
    abstract def runtime_exec(language_name : String, command : String, args : Array(String)? = nil, runtime_version : String? = nil)
    abstract def set_version(language_name : String, version : String?) : Bool
    abstract def set_global_version(language_name : String, version : String) : Bool
    abstract def shell_activation(shell_name : String) : String

    macro finished
      # :nodoc:
      def self.all
        @@runtime_managers ||= {
          {% for subclass in @type.subclasses %}
            {{subclass.name.stringify.split("::").last.downcase}} => {{ subclass.name }}.new,
          {% end %}
        }
      end

      # :nodoc:
      def runtimes
        @runtimes ||= [
          {% for subclass in Runtime.subclasses %}
            {{ subclass.name }}.new(self),
          {% end %}
        ]
      end
    end
  end
end
