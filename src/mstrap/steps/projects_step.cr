module MStrap
  module Steps
    # Runnable as `mstrap projects`, the Project step does the work of fetching,
    # updating, and bootstrapping all configured projects.
    class ProjectsStep < Step
      @has_web_projects = false
      @projects : Array(Project) | Nil

      def self.description
        "Bootstraps configured projects"
      end

      def bootstrap
        logn "==> Bootstrapping projects"

        create_services_internal_yml! if has_web_projects?

        projects.each do |project|
          logn "==> #{project.name}"
          log "--> Fetching: "

          if Dir.exists?(project.path)
            logw "Already fetched"
            unless skip_project_update?
              log "--> Updating: "
              if project.pull
                success "OK"
              else
                logc "Could not update git repo for #{project.name}"
              end
            end
          else
            if project.clone
              success "OK"
            else
              logc "Could not clone git repo for #{project.name}"
            end
          end

          logn "--> Bootstrapping: "
          project.bootstrap(runtime_manager)
          success "Finished bootstrapping #{project.name}"
        end

        restart_internal_services! if has_web_projects?
      end

      private def skip_project_update?
        options.skip_project_update?
      end

      private def projects
        @projects ||= profile.projects.map do |project_def|
          MStrap::Project.for(project_def)
        end
      end

      private def has_web_projects?
        @has_web_projects ||= projects.any?(&.web?)
      end

      private def create_services_internal_yml!
        log "--> Creating/updating default services-internal.yml for web projects: "
        Templates::ServicesInternalYml.new.write_to_config!
        success "OK"
      end

      private def restart_internal_services!
        ServicesStep.new(config, options).bootstrap(
          services_yml: Paths::SERVICES_INTERNAL_YML
        )
      end
    end
  end
end
