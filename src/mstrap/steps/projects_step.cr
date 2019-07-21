module MStrap
  module Steps
    class ProjectsStep < Step
      include Utils::Logging

      @projects : Array(Project) | Nil

      def bootstrap
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

      private def skip_project_update?
        options.skip_project_update?
      end

      private def projects
        @projects ||= profile.projects.map do |project_def|
          MStrap::Project.for(project_def)
        end
      end
    end
  end
end
