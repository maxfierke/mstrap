module MStrap
  module Templates
    class NginxConf
      getter :project

      def initialize(project : Project)
        @project = project
      end

      ECR.def_to_s "#{__DIR__}/nginx.conf.ecr"

      def write_to_config!
        config_path = File.join(Paths::PROJECT_SITES, "#{project.cname}.conf")
        Dir.mkdir_p(Paths::PROJECT_SITES)
        Dir.mkdir_p(Paths::PROJECT_SOCKETS)
        File.write(config_path, to_s, perm: 0o644)
      end
    end
  end
end
