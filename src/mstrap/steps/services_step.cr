module MStrap
  module Steps
    class ServicesStep < Step
      include Utils::Logging
      include Utils::System

      def bootstrap
        logn "==> Setting up managed services"

        if File.exists?(MStrap::Paths::SERVICES_YML)
          ensure_docker!
          bootstrap_services!
        else
          logw "No services.yml found. Please create a configuration at #{MStrap::Paths::SERVICES_YML} to manage Docker services with mstrap."
        end
      end

      private def ensure_docker!
        found_docker = false

        while !(found_docker = cmd "docker-compose version")
          logw "Could not find 'docker-compose'."

          if docker_app_path
            cmd "open -a #{docker_app_path}"

            logn "Opening Docker.app. Please follow the installation prompts and return when Docker is running."
            log "Have you completed the Docker installation prompts? [y/n]: "

            STDIN.gets
          else
            logc "Please ensure docker is installed through the Brewfile or some other means."
          end
        end
      end

      private def bootstrap_services!
        log "---> Starting up docker services: "
        unless start_services
          logc "Could not start up docker services. Check #{MStrap::Paths::LOG_FILE}"
        end
        success "OK"
      end

      private def start_services
        cmd(
          "docker-compose",
          "-f", MStrap::Paths::SERVICES_YML,
          "up", "-d"
        )
      end

      private def docker_app_path
        @docker_app_path ||= if Dir.exists?("/Application/Docker.app")
          "/Application/Docker.app"
        elsif Dir.exists?("#{ENV["HOME"]}/Applications/Docker.app")
          "#{ENV["HOME"]}/Applications/Docker.app"
        else
          nil
        end
      end
    end
  end
end
