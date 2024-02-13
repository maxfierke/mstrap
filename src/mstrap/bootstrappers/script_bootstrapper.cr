module MStrap
  module Bootstrappers
    class ScriptBootstrapper < Bootstrapper
      # :nodoc:
      BOOTSTRAP_SCRIPT = File.join("script", "bootstrap")

      # :nodoc:
      SETUP_SCRIPT = File.join("script", "setup")

      # Executes `script/bootstrap` and `script/setup` (if either exists and are
      # configured to run)
      def bootstrap(project : Project) : Bool
        logd "Found bootstrapping scripts, executing instead of using defaults."

        begin
          ENV["__MSTRAP_EXEC_SCRIPTS"] = "true"

          Dir.cd(project.path) do
            cmd BOOTSTRAP_SCRIPT if File.exists?(BOOTSTRAP_SCRIPT)
            cmd SETUP_SCRIPT if File.exists?(SETUP_SCRIPT)
          end
        ensure
          ENV.delete("__MSTRAP_EXEC_SCRIPTS")
        end

        true
      end

      # Whether project has any bootstrapping/setup scripts a-la
      # [`scripts-to-rule-them-all`](https://github.com/github/scripts-to-rule-them-all)
      def self.has_scripts?(project)
        [BOOTSTRAP_SCRIPT, SETUP_SCRIPT].any? do |script_path|
          File.exists?(File.join(project.path, script_path))
        end
      end
    end
  end
end
