module MStrap
  module Steps
    class ProjectsStep < Step
      include Utils::Logging

      @projects : Array(Project) | Nil

      def bootstrap
        logn "==> Bootstrapping projects"
        projects.not_nil!.each do |project|
          logn "#### #{project.name}"
          log "---> Fetching: "

          if Dir.exists?(project.path)
            logw "Already fetched"
            unless skip_project_update?
              log "---> Updating: "
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

          log "---> Bootstrapping: "
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
