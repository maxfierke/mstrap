module MStrap
  module Steps
    class ComposeStep < Step
      include Utils::Logging
      include Utils::System

      def bootstrap
        ensure_docker!
        Process.exec("docker-compose", ["-f", MStrap::Paths::SERVICES_YML] + args)
      end

      private def ensure_docker!
        unless cmd "docker-compose version"
          logw "Could not find 'docker-compose'."
          logc "Please ensure you've done a full run of mstrap and docker has been installed"
        end
      end
    end
  end
end
