module MStrap
  module Steps
    class ComposeStep < Step
      include Utils::Docker

      def self.description
        "Wrapper around `docker-compose` and all loaded profile's services.yml"
      end

      def bootstrap
        ensure_docker_compose!

        file_args = docker_compose_file_args

        if file_args.empty?
          logc "No services.yml found. Please create one at #{Paths::SERVICES_YML}, or within a profile."
        end

        Process.exec("docker-compose", file_args + args)
      end
    end
  end
end
