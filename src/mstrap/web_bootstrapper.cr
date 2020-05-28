module MStrap
  # The `WebBootstrapper` is responsible for bootstrapping web-based projects.
  # Currently, this is just setting up an NGINX configuration for the project.
  class WebBootstrapper
    include Utils::Env
    include Utils::Logging
    include Utils::System

    # Project to run bootstrapper on
    getter :project

    def initialize(@project : Project)
    end

    # Executes the bootstrapper
    def bootstrap
      Dir.mkdir_p(Paths::PROJECT_CERTS)
      Dir.mkdir_p(Paths::PROJECT_SITES)
      Dir.mkdir_p(Paths::PROJECT_SOCKETS)

      if cmd("command -v mkcert > /dev/null 2>&1")
        Dir.cd(Paths::PROJECT_CERTS) do
          unless cmd("mkcert -install") && cmd("mkcert #{project.hostname} '*.#{project.hostname}'")
            logc "An error occurred while making a cert for #{project.hostname}"
          end
        end
      else
        logw "mkcert not found. Skipping cert setup."
      end

      Templates::NginxConf.new(project).write_to_config!
    end
  end
end
