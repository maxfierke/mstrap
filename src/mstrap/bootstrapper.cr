module MStrap
  abstract class Bootstrapper
    include DSL

    def initialize(@config : Configuration)
    end

    def self.for(config : Configuration, project : Project) : Array(Bootstrapper)
      bootstrappers = Array(Bootstrapper).new

      if project.run_scripts? && Bootstrappers::ScriptBootstrapper.has_scripts?(project)
        bootstrappers << Bootstrappers::ScriptBootstrapper.new(config)
      else
        bootstrappers << Bootstrappers::DefaultBootstrapper.new(config)

        if project.web?
          bootstrappers << Bootstrappers::WebBootstrapper.new(config)
        end
      end

      bootstrappers
    end

    abstract def bootstrap(project : Project) : Bool

    protected getter :config
  end
end
