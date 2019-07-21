module MStrap
  class Project
    extend Utils::Logging
    include Utils::Logging
    include Utils::System

    ABSOLUTE_REPO_URL_REGEX = /\A(git|https?|ftps?|ssh|file):\/\//
    SCP_REPO_REGEX = /\A(.+@)?[\w\d\.\-_]+:/

    BOOTSTRAP_SCRIPT = File.join("script", "bootstrap")

    @cname : String
    @hostname : String
    @name : String
    @path : String
    @port : Int32?
    @repo : String
    @run_scripts = true
    @runtime : String
    @upstream : String?
    @websocket : Bool
    @web : Bool

    getter :cname, :hostname, :name, :path, :port, :repo, :runtime, :websocket
    getter? :run_scripts, :web

    def self.for(project_def : Defs::ProjectDef)
      case project_def.runtime
      when "javascript"
        Projects::JavascriptProject
      when "python"
        Projects::PythonProject
      when "ruby"
        Projects::RubyProject
      else
        project_def.runtime = "unknown"
        Project
      end.new(project_def)
    end

    def initialize(project_def : Defs::ProjectDef)
      @cname = project_def.cname
      @name = project_def.name
      @hostname = project_def.hostname || "#{cname}.localhost"
      @path = File.join(MStrap::Paths::SRC_DIR, project_def.path_present? ? project_def.path.not_nil! : cname)
      @port = project_def.port
      @repo = project_def.repo
      @run_scripts = project_def.run_scripts
      @runtime = project_def.runtime
      @upstream = project_def.upstream
      @websocket = project_def.websocket
      @web = if project_def.web_present?
        project_def.web
      else
        project_def.hostname_present? || project_def.port_present? || project_def.upstream_present?
      end
    end

    def git_uri
      @git_uri ||= if repo =~ ABSOLUTE_REPO_URL_REGEX || repo =~ SCP_REPO_REGEX
        repo
      else
        "git@github.com:#{repo}.git"
      end
    end

    def upstream
      @upstream ||= begin
        if port = @port
          "localhost:#{port}"
        else
          "unix:#{Paths::PROJECT_SOCKETS}/#{cname}"
        end
      end
    end

    def clone
      cmd("git", "clone", git_uri, path)
    end

    def pull
      Dir.cd(path) do
        git_checkpoint do
          success = if current_branch != "master"
            cmd("git checkout master") && cmd("git pull origin master --rebase") && cmd("git checkout -")
          else
            cmd "git pull origin master --rebase"
          end

          unless success
            logw "Failed to update 'master' branch from remote. There may be a problem that needs to be resolved manually."
          end

          success
        end
      end
    end

    def current_branch
      `git rev-parse --abbrev-ref HEAD`.chomp
    end

    def git_checkpoint
      stash_message = "MSTRAP CHECKPOINT #{Time.now.to_unix}"

      begin
        cmd("git", "stash", "push", "-u", "-m", stash_message)
        yield
      ensure
        if cmd("git stash list | grep '#{stash_message}'")
          cmd "git stash pop"
        end
      end
    end

    def bootstrap
      if File.exists?(File.join(path, BOOTSTRAP_SCRIPT)) && run_scripts?
        logd "Found #{BOOTSTRAP_SCRIPT}, executing instead of using '#{runtime}' defaults."
        Dir.cd(path) do
          cmd BOOTSTRAP_SCRIPT
        end
      else
        logd "Bootstrapping '#{name}' with runtime '#{runtime}' defaults."
        default_bootstrap
      end
    end

    protected def default_bootstrap
      if web?
        logd "'#{name}' is a web project. Running web bootstrapper."
        WebBootstrapper.new(self).bootstrap
      end
    end
  end
end
