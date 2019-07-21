module MStrap
  class Project
    BOOTSTRAP_SCRIPT = File.join("script", "bootstrap")

    include Utils::System

    alias ProjectHash = Hash(String, Array(String) | String | Int32 | Nil)

    @cname : String
    @name : String
    @path : String
    @repo : String
    @run_scripts = true
    @type : String

    getter :name, :cname, :path, :repo, :type
    getter? :run_scripts

    def self.for(project_def : Defs::ProjectDef)
      case project_def.type
      when "javascript"
        Projects::JavascriptProject
      when "python"
        Projects::PythonProject
      when "rails"
        Projects::RailsProject
      when "ruby"
        Projects::RubyProject
      when "web"
        Projects::WebProject
      else
        Project
      end.new(project_def)
    end

    def initialize(project_def : Defs::ProjectDef)
      @name = project_def.name
      @cname = project_def.cname
      @path = File.join(MStrap::Paths::SRC_DIR, project_def.path_present? ? project_def.path.not_nil! : cname)
      @repo = project_def.repo
      @run_scripts = project_def.run_scripts
      @type = project_def.type
    end

    def git_uri
      @git_uri ||= "git@github.com:#{repo}.git"
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
        Dir.cd(path) do
          cmd BOOTSTRAP_SCRIPT
        end
      else
        default_bootstrap
      end
    end

    protected def default_bootstrap
    end
  end
end
