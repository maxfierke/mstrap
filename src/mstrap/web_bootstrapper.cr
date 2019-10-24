module MStrap
  # The `WebBootstrapper` is responsible for bootstrapping web-based projects.
  # Currently, this is just setting up an NGINX configuration for the project.
  class WebBootstrapper
    include Utils::System

    # Project to run bootstrapper on
    getter :project

    def initialize(@project : Project)
    end

    # Executes the bootstrapper
    def bootstrap
      Templates::NginxConf.new(project).write_to_config!
    end
  end
end
