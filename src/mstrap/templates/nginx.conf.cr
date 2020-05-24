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
        "#{project.hostname}.pem"
      end

      def cert_key_name
        "#{project.hostname}-key.pem"
      end

      def has_cert?
        cert_path = File.join(Paths::PROJECT_CERTS, cert_name)
        File.exists?(cert_path)
      end

      def nginx_http_port
        {% if flag?(:linux) %}
          80
        {% else %}
          8080
        {% end %}
      end

      def nginx_https_port
        {% if flag?(:linux) %}
          443
        {% else %}
          8443
        {% end %}
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
