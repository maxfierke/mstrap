module MStrap
  class ProjectBootstrapper
    include Utils::System

    getter :project

    def initialize(project : Project)
      @project = project
    end

    def bootstrap
      setup_nginx_conf
      Dir.cd(project.path) do
        setup_rbenv
        setup_nodenv
      end
    end

    private def setup_nginx_conf
      project = @project
      return unless project.is_a?(Projects::WebProject)

      nginx_conf_tpl = FS.get("files/nginx.conf.erb").gets_to_end
      rc_nginx_conf_path = File.join(MStrap::Paths::RC_DIR, "nginx_#{project.cname}.conf.erb")

      File.write(rc_nginx_conf_path, nginx_conf_tpl)

      cmd(
        "brew",
        "setup-nginx-conf",
        "--extra-val=upstream=#{project.nginx_upstream}",
        project.hostname,
        project.path,
        rc_nginx_conf_path
      )

      # Cleanup after ourselves
      FileUtils.rm(rc_nginx_conf_path)
    end

    private def setup_rbenv
      project = @project
      return unless project.responds_to?(:with_project_ruby)
      project.with_project_ruby do
        cmd "brew bootstrap-rbenv-ruby"
      end
    end

    private def setup_nodenv
      node_version_path = File.join(project.path, ".node-version")
      return unless File.exists?(node_version_path)
      node_version = File.read(node_version_path).chomp
      cmd({ "NODENV_VERSION" => node_version }, "brew", "bootstrap-nodenv-node")
    end
  end
end
