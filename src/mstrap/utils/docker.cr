module MStrap
  module Utils
    module Docker
      @docker_app_path : String? = nil

      DOCKER_APT_KEY_FINGERPRINT = "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"

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
          if cmd("docker version", quiet: true)
            return
          end

          arch = `uname -m`.chomp
          distro_name = MStrap.linux_distro
          distro_codename = MStrap.linux_distro_codename

          if MStrap.debian_distro?
            # https://docs.docker.com/engine/install/ubuntu/#installation-methods
            cmd "sudo apt-get update"
            cmd "sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
            cmd "curl -fsSL https://download.docker.com/linux/#{distro_name}/gpg | sudo apt-key add -"
            cmd "sudo add-apt-repository \"deb [arch=#{arch}] https://download.docker.com/linux/#{distro_name} #{distro_codename} stable\""
            cmd "sudo apt-get update"
            cmd "sudo apt-get -y install docker-ce docker-ce-cli containerd.io"
          elsif MStrap.fedora?
            cmd "sudo dnf -y install dnf-plugins-core"
            cmd "sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo"
            cmd "sudo dnf install docker-ce docker-ce-cli containerd.io"
          elsif MStrap.centos?
            cmd "sudo yum install -y yum-utils"
            cmd "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
            cmd "sudo yum install -y docker-ce docker-ce-cli containerd.io"
          elsif MStrap.rhel?
            logc <<-REDHAT
            docker-ce (community edition) is not officially supported on RHEL.
            You'll need to install it manually via supported channels or use
            docker-ee (enterprise edition) instead.
            REDHAT
          else
            logw "Cannot determine your distribution, so skipping Docker installation."
            logw "This will error if Docker is not installed."
          end
        {% end %}
      end
    end
  end
end
