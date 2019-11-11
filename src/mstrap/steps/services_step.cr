module MStrap
  module Steps
    # Runnable as `mstrap services`, the Services step creates or updates any
    # mstrap-managed Docker services.
    class ServicesStep < Step
      include Utils::Docker
      include Utils::Env
      include Utils::Logging
      include Utils::System

      def self.description
        "(Re)creates mstrap-managed docker-compose services"
      end

      def bootstrap
        bootstrap(nil)
      end

      # :nodoc:
      def bootstrap(services_yml)
        if services_yml && File.exists?(services_yml)
          file_args = ["-f", services_yml]
        else
          file_args = docker_compose_file_args
        end

        if file_args.any?
          ensure_docker_compose!
          logn "==> Setting up managed services"
          unless start_services(file_args)
            logc "Could not start up docker services. Check #{MStrap::Paths::LOG_FILE}"
          end
          success "OK"
        else
          logw "No services.yml found. Please create one at #{Paths::SERVICES_YML}, or within a profile."
        end
      end

      private def start_services(file_args)
        cmd("docker-compose", file_args + ["up", "-d"])
      end
    end
  end
end
