module MStrap
  # The `WebBootstrapper` is responsible for bootstrapping web-based projects.
  # Currently, this is just setting up an NGINX configuration for the project.
  class WebBootstrapper
    include DSL

    # Project to run bootstrapper on
    getter :project

    def initialize(project : Project)
      @project = project
      @mkcert = Mkcert.new
    end

    # Executes the bootstrapper
    def bootstrap
      if mkcert.installed?
        Dir.cd(Paths::PROJECT_CERTS) do
          mkcert.install!
          mkcert.install_cert!(project.hostname)
        end
      else
        logw "mkcert not found. Skipping cert setup."
      end

      Templates::NginxConf.new(project).write_to_config!
    end

    private getter :mkcert
  end
end
