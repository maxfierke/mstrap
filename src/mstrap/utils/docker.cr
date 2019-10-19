require "./env"
require "./logging"
require "./system"

module MStrap
  module Utils
    module Docker
      include Logging
      include System

      def docker_app_path
        @docker_app_path ||= if Dir.exists?("/Applications/Docker.app")
          "/Applications/Docker.app"
        elsif Dir.exists?("#{ENV["HOME"]}/Applications/Docker.app")
          "#{ENV["HOME"]}/Applications/Docker.app"
        else
          nil
        end
      end

      def docker_compose_file_args
        file_args = [] of String

        if File.exists?(Paths::SERVICES_INTERNAL_YML)
          file_args << "-f"
          file_args << Paths::SERVICES_INTERNAL_YML
        end

        config.profile_configs.each do |profile_config|
          services_yml_path = File.join(profile_config.dir, "services.yml")

          if File.exists?(services_yml_path)
            file_args << "-f"
            file_args << services_yml_path
          end
        end

        file_args
      end

      private def ensure_docker_compose!
        found_docker = false

        while !(found_docker = cmd "docker-compose version")
          logw "Could not find 'docker-compose'."

          if docker_app_path && STDIN.tty?
            cmd "open -a #{docker_app_path}"

            logn "Opening Docker.app. Please follow the installation prompts and return when Docker is running."
            log "Have you completed the Docker installation prompts? [y/n]: "

            STDIN.gets
          else
            logc "Please ensure docker is installed through the Brewfile or some other means."
          end
        end
      end
    end
  end
end
