module MStrap
  module Steps
    class ProjectsStep < Step
      include Utils::Logging

      @projects : Array(Project) | Nil

      def initialize(options = CLIOptions)
        super
        @config_path = options[:config_path].as(String)
      end

      def bootstrap
        Dir.mkdir_p(Paths::PROJECT_SOCKETS)

        logn "==> Fetching, updating, and bootstrapping projects"
        projects.not_nil!.each do |project|
          log "---> Fetching #{project.name}: "

          if Dir.exists?(project.path)
            logw "Already fetched #{project.name}"
            unless skip_project_update?
              log "---> Updating #{project.name}: "
              if project.pull
                success "OK"
              else
                logc "Could not update git repo for #{project.cname}"
              end
            end
          else
            if project.clone
              success "OK"
            else
              logc "Could not clone git repo for #{project.cname}"
            end
          end

          log "---> Bootstrapping #{project.name}: "
          project.bootstrap
          success "OK"
        end
      end

      private getter :config_path

      private def skip_project_update?
        !!options[:skip_project_update]?
      end

      private def projects
        @projects ||= MStrap::Project.from_yaml(config_path)
      end
    end
  end
end
