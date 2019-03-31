module MStrap
  module Projects
    class WebProject < Project
      @hostname : String
      @port : Int32?
      @upstream : String?

      getter :hostname, :port

      def initialize(project_config : YAML::Any)
        super(project_config)
        @hostname = project_config["hostname"]? ? project_config["hostname"].as_s : "#{cname}.localhost"
        @port = project_config["port"]? ? project_config["port"].as_s.to_i : nil
        @nginx_upstream = project_config["upstream"]? ? project_config["upstream"].as_s : nil
      end

      def initialize(project_config : Project::ProjectHash)
        super(project_config)
        @hostname = project_config["hostname"]? ? project_config["hostname"].as(String) : "#{cname}.localhost"
        @port = project_config["port"]? ? project_config["port"].as(Int32) : nil
        @nginx_upstream = project_config["upstream"]?.as(String?)
      end

      def nginx_upstream
        @nginx_upstream ||= begin
          if port = @port
            "localhost:#{port}"
          else
            "unix:#{MStrap::Paths::PROJECT_SOCKETS}/#{cname}"
          end
        end
      end

      protected def default_bootstrap
        super
        setup_nginx_conf
      end

      private def setup_nginx_conf
        nginx_conf_tpl = FS.get("nginx.conf.erb").gets_to_end
        rc_nginx_conf_path = File.join(MStrap::Paths::RC_DIR, "nginx_#{cname}.conf.erb")

        File.write(rc_nginx_conf_path, nginx_conf_tpl)

        cmd(
          "brew",
          "setup-nginx-conf",
          "--extra-val=upstream=#{nginx_upstream}",
          hostname,
          path,
          rc_nginx_conf_path
        )

        # Cleanup after ourselves
        FileUtils.rm(rc_nginx_conf_path)
      end
    end
  end
end
