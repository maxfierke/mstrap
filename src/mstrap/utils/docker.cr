module MStrap
  module Utils
    module Docker
      # Returns the path to an installed Docker for Mac application
      def docker_app_path
        @docker_app_path ||= if Dir.exists?("/Applications/Docker.app")
                               "/Applications/Docker.app"
                             elsif Dir.exists?("#{ENV["HOME"]}/Applications/Docker.app")
                               "#{ENV["HOME"]}/Applications/Docker.app"
                             else
                               nil
                             end
      end

      # Returns a collection of flags for `docker-compose` to use `services.yml`
      # for the loaded profiles.
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

      protected def ensure_docker_compose!
        found_docker = false

        while !(found_docker = cmd("docker-compose version", quiet: true))
          logw "Could not find 'docker-compose'."

          if docker_app_path && STDIN.tty?
            cmd "open -a #{docker_app_path}", quiet: true

            logn "Opening Docker.app. Please follow the installation prompts and return when Docker is running."
            log "Have you completed the Docker installation prompts? [y/n]: "

            STDIN.gets
          else
            logc "Please ensure docker is installed through the Brewfile or some other means."
          end
        end
      end

      protected def install_docker!
        unless docker_app_path || cmd "brew cask install docker"
          logc "Could not install docker via Homebrew cask"
        end
      end
    end
  end
end
