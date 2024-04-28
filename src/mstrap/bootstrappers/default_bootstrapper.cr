module MStrap
  module Bootstrappers
    class DefaultBootstrapper < Bootstrapper
      # Conventional bootstrapping from mstrap. This will auto-detect the runtimes
      # used by the project and run the standard bootstrapping for each runtime.
      # This **does not** run any bootstrapping scripts, and is used mainly for
      # calling into conventional bootstrapping within a project's
      # `script/bootstrap` or `script/setup` from `mstrap project`.
      def bootstrap(project : Project) : Bool
        logd "Bootstrapping '#{project.name}' with runtime defaults."

        runtime_impls(project).each_value do |runtime|
          Dir.cd(project.path) do
            if runtime.matches?
              logd "Detected #{runtime.language_name}. Installing #{runtime.language_name}, project #{runtime.language_name} packages, and other relevant dependencies"
              runtime.setup
            end
          end
        end

        true
      end

      def runtime_impls(project)
        if project_runtimes = project.runtimes
          # Just the ones specified in the config, including empty
          config.runtimes.select do |_, runtime|
            project_runtimes.includes?(runtime.language_name)
          end
        else
          # Default to all, if unspecified
          config.runtimes
        end
      end
    end
  end
end
