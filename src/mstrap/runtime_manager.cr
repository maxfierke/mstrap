module MStrap
  abstract class RuntimeManager
    include DSL

    @runtimes : Array(Runtime)?

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
    abstract def supported_languages : Array(String)

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
      def self.resolve_managers(config_def : Defs::ConfigDef) : Array(RuntimeManager)
        default_runtime_manager = self.for(config_def.runtimes.default_manager)
        managers = [default_runtime_manager]

        config_def.runtimes.runtimes.map(&.manager).uniq!.each do |manager_name|
          next if !manager_name
          managers << RuntimeManager.for(manager_name)
        end

        managers
      end

      # :nodoc:
      def self.resolve_runtimes(config_def : Defs::ConfigDef) : Hash(String, Runtime)
        impls = Hash(String, Runtime).new
        default_manager = {{ @type }}.all[config_def.runtimes.default_manager]

        {% for subclass, index in Runtime.subclasses %}
          {% language_name = subclass.name.stringify.split("::").last.downcase %}

          %runtime_def{index} = config_def.runtimes.runtimes.find { |r| r.name == {{ language_name }} }

          if %runtime_def{index} && (runtime_manager_name = %runtime_def{index}.manager)
            runtime_manager = self.for(runtime_manager_name)

            if !runtime_manager.supported_languages.includes?({{ language_name }})
              raise UnsupportedLanguageRuntimeManagerError.new(runtime_manager.name, {{ language_name }})
            end

            impls[{{language_name}}] = {{ subclass.name }}.new(runtime_manager)
          elsif default_manager.supported_languages.includes?({{ language_name }})
            impls[{{language_name}}] = {{ subclass.name }}.new(default_manager)
          else
            raise UnsupportedLanguageRuntimeManagerError.new(default_manager.name, {{ language_name }})
          end
        {% end %}

        impls
      end
    end
  end
end
