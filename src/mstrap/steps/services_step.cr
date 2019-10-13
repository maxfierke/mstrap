module MStrap
  module Steps
    class ServicesStep < Step
      include Utils::Docker

      def self.description
        "(Re)creates mstrap-managed docker-compose services"
      end

      def bootstrap(services_yml = nil)
        ensure_docker_compose!

        if services_yml && File.exists?(services_yml)
          file_args = ["-f", services_yml]
        else
          file_args = docker_compose_file_args
        end

        if file_args.any?
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
