module MStrap
  # :nodoc:
  module Templates
    class NginxConf
      @upstream_name : String? = nil

      getter :project

      def initialize(project : Project)
        @project = project
      end

      ECR.def_to_s "#{__DIR__}/nginx.conf.ecr"

      def cert_name
        # +1 suffix is for wildcard
        "#{project.hostname}+1.pem"
      end

      def cert_key_name
        # +1 suffix is for wildcard
        "#{project.hostname}+1-key.pem"
      end

      def has_cert?
        cert_path = File.join(Paths::PROJECT_CERTS, cert_name)
        File.exists?(cert_path)
      end

      def nginx_http_port
        80
      end

      def nginx_https_port
        443
      end

      def upstream_name
        @upstream_name ||= project.cname.gsub(/[^A-Za-z0-9_]/, "_")
      end

      def write_to_config!
        config_path = File.join(Paths::PROJECT_SITES, "#{project.cname}.conf")
        File.write(config_path, to_s, perm: 0o644)
      end
    end
  end
end
