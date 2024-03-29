module MStrap
  class Docker
    include DSL

    @app_path : String? = nil
    @requires_sudo : Bool? = nil

    # :nodoc:
    APT_KEY_FINGERPRINT = "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"

    # :nodoc:
    DOCKER_CE_PACKAGE_NAMES = %w[
      docker-ce
      docker-ce-cli
      containerd.io
      docker-buildx-plugin
      docker-compose-plugin
    ]

    # Returns the path to an installed Docker Desktop application
    def app_path
      {% if flag?(:darwin) %}
        @app_path ||=
          if Dir.exists?("/Applications/Docker.app")
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

    # Returns a collection of flags for `docker compose` to use `services.yml`
    # for the loaded profiles.
    def compose_file_args(config)
      file_args = [] of String

      has_files = false

      if File.exists?(Paths::SERVICES_INTERNAL_YML)
        file_args << "-f"
        file_args << Paths::SERVICES_INTERNAL_YML
        has_files = true
      end

      config.profile_configs.each do |profile_config|
        services_yml_path = File.join(profile_config.dir, "services.yml")

        if File.exists?(services_yml_path)
          file_args << "-f"
          file_args << services_yml_path
          has_files = true
        end
      end

      if has_files
        file_args << "-p"
        file_args << "mstrap"
      end

      file_args
    end

    # Returns whether Docker requires sudo to run (i.e. is the user in the docker group or not)
    def requires_sudo?
      requires_sudo = @requires_sudo
      return requires_sudo unless requires_sudo.nil?
      @requires_sudo =
        {% if flag?(:darwin) %}
          false
        {% else %}
          !`groups`.chomp.split(" ").includes?("docker")
        {% end %}
    end

    # Check for `docker compose` and raise if not found. On macOS, this will loop until you confirm the
    # command line tools have been installed for Docker Desktop
    def ensure_compose!
      while !cmd("docker compose version", quiet: true, sudo: requires_sudo?)
        logw "Could not execute 'docker compose'"

        if app_path && STDIN.tty?
          cmd "open -a #{app_path}", quiet: true

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

    # Installs Docker on the target system, if it's not installed.
    # On certain platforms, this may exit `mstrap` and print a message about
    # requiring a reboot.
    def install!
      {% if flag?(:darwin) %}
        unless app_path || cmd "brew cask install docker"
          logc "Could not install docker via Homebrew cask"
        end
      {% elsif flag?(:linux) %}
        if !cmd("docker version", quiet: true, sudo: requires_sudo?) || !cmd("docker compose version", quiet: true, sudo: requires_sudo?)
          logn "Docker and/or Docker Compose has not been installed. Attempting to install Docker now."
          logn "You may be prompted by sudo"

          success =
            if MStrap::Linux.arch_distro?
              install_docker_archlinux!
            elsif MStrap::Linux.debian_distro?
              install_docker_debian!
            elsif MStrap::Linux.rhel_distro?
              install_docker_rhel!
            else
              logw "Cannot determine your distribution, so skipping Docker installation."
              logw "This will error if Docker is not installed."
              true
            end

          unless success
            logc "Could not install Docker successfully."
          end

          logn "Starting docker and setting docker to start on boot"
          cmd "sudo systemctl enable docker" && "sudo systemctl start docker"

          logn "Adding user to 'docker' group for sudoless docker: "
          if !`groups`.includes?("docker") && cmd("sudo usermod -aG docker #{ENV["USER"]}")
            logw "Could not add current user to 'docker' group. You will have to do this manually to run docker without sudo."
          else
            success "OK. You may need to log-out and back in, or restart for it to take effect."
          end
        end
      {% end %}
    end

    private def install_docker_archlinux!
      logn "Installing Docker from ArchLinux repos"
      MStrap::Platform.install_packages!(["docker", "docker-buildx", "docker-compose"])
    end

    private def install_docker_centos!
      # https://docs.docker.com/engine/install/centos/#installation-methods
      logn "Installing Docker from Official Docker Repos"
      success = cmd("sudo yum install -y yum-utils") &&
                cmd("sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo") &&
                MStrap::Platform.install_packages!(DOCKER_CE_PACKAGE_NAMES)

      success
    end

    private def install_docker_debian!
      distro_name = MStrap::Linux.distro
      distro_codename = MStrap::Linux.distro_codename

      uname_m = `uname -m`.chomp
      docker_arch =
        case uname_m
        when "x86_64", "amd64"
          "amd64"
        when "aarch64", "arm64"
          "arm64"
        else
          # TODO: should we error instead?
          uname_m
        end

      # https://docs.docker.com/engine/install/ubuntu/#installation-methods
      logn "Installing Docker from Official Docker Repos"
      success = cmd("sudo apt-get update") &&
                cmd("sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common") &&
                cmd("curl -fsSL https://download.docker.com/linux/#{distro_name}/gpg | sudo apt-key add -") &&
                cmd("sudo add-apt-repository \"deb [arch=#{docker_arch}] https://download.docker.com/linux/#{distro_name} #{distro_codename} stable\"") &&
                cmd("sudo apt-get update") &&
                MStrap::Platform.install_packages!(DOCKER_CE_PACKAGE_NAMES)

      success
    end

    private def install_docker_fedora!
      # https://docs.docker.com/engine/install/fedora/#installation-methods
      logn "Installing Docker from Official Docker Repos"
      success = cmd("sudo dnf -y install dnf-plugins-core") &&
                cmd("sudo dnf config-manager -y --add-repo https://download.docker.com/linux/fedora/docker-ce.repo") &&
                MStrap::Platform.install_packages!(DOCKER_CE_PACKAGE_NAMES)

      success
    end

    private def install_docker_rhel!
      if MStrap::Linux.centos?
        install_docker_centos!
      elsif MStrap::Linux.fedora?
        install_docker_fedora!
      else
        logc <<-REDHAT
          docker-ce (community edition) is not officially supported on RHEL.
          You'll need to install it manually via supported channels or via RedHat
          directly.
        REDHAT
        false
      end
    end
  end
end
