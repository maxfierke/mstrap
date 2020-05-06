module MStrap
  # :nodoc:
  module Templates
    class ServicesInternalYml
      getter :project_sites_path, :project_sockets_path

      def initialize
        @project_sites_path = Paths::PROJECT_SITES
        @project_sockets_path = Paths::PROJECT_SOCKETS
      end

      ECR.def_to_s "#{__DIR__}/services-internal.yml.ecr"

      def use_host_network?
        {{ flag?(:linux) }}
      end

      def write_to_config!
        File.write(Paths::SERVICES_INTERNAL_YML, to_s, perm: 0o644)
      end
    end
  end
end
