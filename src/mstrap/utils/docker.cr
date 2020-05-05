module MStrap
  module Utils
    module Docker
      @docker_app_path : String? = nil
      @docker_requires_sudo : Bool? = nil

      # :nodoc:
      DOCKER_APT_KEY_FINGERPRINT = "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"

      # :nodoc:
      DOCKER_COMPOSE_VERSION = "1.25.5"

      # :nodoc:
      DOCKER_COMPOSE_PATH = "/usr/local/bin/docker-compose"

      # Returns the path to an installed Docker for Mac application
      def docker_app_path
        {% if flag?(:darwin) %}
          @docker_app_path ||= if Dir.exists?("/Applications/Docker.app")
                                 "/Applications/Docker.app"
                               elsif Dir.exists?("#{ENV["HOME"]}/Applications/Docker.app")
                                 "#{ENV["HOME"]}/Applications/Docker.app"
                               else
                                 nil
                               end
        {% else %}
          nil
        {% end %}
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

      def docker_requires_sudo?
        requires_sudo = @docker_requires_sudo
        return requires_sudo unless requires_sudo.nil?
        @docker_requires_sudo = {% if flag?(:darwin) %}
                                  false
                                {% else %}
                                  !`groups`.chomp.split(" ").includes?("docker")
                                {% end %}
      end

      protected def ensure_docker_compose!
        found_docker = false

        while !(found_docker = cmd("docker-compose version", quiet: true, sudo: docker_requires_sudo?))
          logw "Could not find 'docker-compose'."

          if docker_app_path && STDIN.tty?
            cmd "open -a #{docker_app_path}", quiet: true

            logn "Opening Docker.app. Please follow the installation prompts and return when Docker is running."
            log "Have you completed the Docker installation prompts? [y/n]: "

            STDIN.gets
          else
            {% if flag?(:darwin) %}
              logc "Please ensure docker is installed through the Brewfile or some other means."
            {% else %}
              logc "Please ensure docker is installed via your package manager or some other means."
            {% end %}
          end
        end
      end

      protected def install_docker!
        {% if flag?(:darwin) %}
          unless docker_app_path || cmd "brew cask install docker"
            logc "Could not install docker via Homebrew cask"
          end
        {% elsif flag?(:linux) %}
          if !cmd("docker version", quiet: true, sudo: docker_requires_sudo?)
            logn "Docker has not been installed. Attempting to install Docker now."
            logn "You may be prompted by sudo"
            arch = `uname -m`.chomp
            distro_name = MStrap.linux_distro
            distro_codename = MStrap.linux_distro_codename

            success = if MStrap.debian_distro?
                        # https://docs.docker.com/engine/install/ubuntu/#installation-methods
                        logn "Installing Docker from Official Docker Repos"
                        cmd("sudo apt-get update") &&
                          cmd("sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common") &&
                          cmd("curl -fsSL https://download.docker.com/linux/#{distro_name}/gpg | sudo apt-key add -") &&
                          cmd("sudo add-apt-repository \"deb [arch=#{arch}] https://download.docker.com/linux/#{distro_name} #{distro_codename} stable\"") &&
                          cmd("sudo apt-get update") &&
                          cmd("sudo apt-get -y install docker-ce docker-ce-cli containerd.io")
                      elsif MStrap.fedora?
                        # https://docs.docker.com/engine/install/fedora/#installation-methods
                        logn "Installing Docker from Official Docker Repos"
                        cmd("sudo dnf -y install dnf-plugins-core") &&
                          cmd("sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo") &&
                          cmd("sudo dnf install docker-ce docker-ce-cli containerd.io")
                      elsif MStrap.centos?
                        # https://docs.docker.com/engine/install/centos/#installation-methods
                        logn "Installing Docker from Official Docker Repos"
                        cmd("sudo yum install -y yum-utils") &&
                          cmd("sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo") &&
                          cmd("sudo yum install -y docker-ce docker-ce-cli containerd.io")
                      elsif MStrap.rhel?
                        logc <<-REDHAT
                        docker-ce (community edition) is not officially supported on RHEL.
                        You'll need to install it manually via supported channels or use
                        docker-ee (enterprise edition) instead.
                        REDHAT
                        false
                      else
                        logw "Cannot determine your distribution, so skipping Docker installation."
                        logw "This will error if Docker is not installed."
                        true
                      end
            unless success
              logc "Could not install Docker successfully."
            end

            logn "Adding user to 'docker' group for sudoless docker: "
            if cmd("sudo usermod -aG docker #{ENV["USER"]}") && cmd("newgrp docker")
              logw "Could not add current user to 'docker' group. You will have to do this manually to run docker without sudo."
            else
              success "OK. You may need to log-out and back in, or restart for it to take effect."
            end
          end

          if !cmd("docker-compose version", quiet: true, sudo: docker_requires_sudo?)
            logn "docker-compose has not been installed. Attempting to install docker-compose now."
            logn "You may be prompted by sudo"
            arch = `uname -m`.chomp

            unless cmd("sudo curl -L 'https://github.com/docker/compose/releases/download/#{DOCKER_COMPOSE_VERSION}/docker-compose-linux-#{arch}' -o #{DOCKER_COMPOSE_PATH}") &&
                   cmd("sudo chmod +x #{DOCKER_COMPOSE_PATH}")
              logc "Could not install docker-compose successfully"
            end
          end
        {% end %}
      end
    end
  end
end
