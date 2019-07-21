module MStrap
  class WebBootstrapper
    include Utils::System

    getter :project

    def initialize(@project : Project)
    end

    def bootstrap
      setup_nginx_conf!
    end

    private def setup_nginx_conf!
      nginx_conf_tpl = FS.get("nginx.conf.erb").gets_to_end
      rc_nginx_conf_path = File.join(Paths::PROJECT_SITES, "#{project.cname}.conf.erb")

      Dir.mkdir_p(Paths::PROJECT_SITES)
      Dir.mkdir_p(Paths::PROJECT_SOCKETS)
      File.write(rc_nginx_conf_path, nginx_conf_tpl)

      cmd(
        "brew",
        "setup-nginx-conf",
        project.hostname,
        project.path,
        rc_nginx_conf_path,
        "--extra-val=upstream=#{project.upstream}",
        "--extra-val=websocket=#{project.websocket}"
      )
    ensure
      # Cleanup after ourselves
      if rc_nginx_conf_path && File.exists?(rc_nginx_conf_path)
        FileUtils.rm(rc_nginx_conf_path)
      end
    end
  end
end
