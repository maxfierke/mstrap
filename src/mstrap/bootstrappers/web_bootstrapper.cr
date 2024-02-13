module MStrap
  module Bootstrappers
    # The `WebBootstrapper` is responsible for bootstrapping web-based projects.
    # Currently, this is just setting up an NGINX configuration for the project.
    class WebBootstrapper < Bootstrapper
      include DSL

      def initialize(@config : Configuration)
        super
        @mkcert = Mkcert.new
      end

      # Executes the bootstrapper
      def bootstrap(project : Project) : Bool
        logd "'#{project.name}' is a web project. Running web bootstrapper."

        if mkcert.installed?
          Dir.cd(Paths::PROJECT_CERTS) do
            mkcert.install!
            mkcert.install_cert!(project.hostname)
          end
        else
          logw "mkcert not found. Skipping cert setup."
        end

        Templates::NginxConf.new(project).write_to_config!
        true
      end

      private getter :mkcert
    end
  end
end
