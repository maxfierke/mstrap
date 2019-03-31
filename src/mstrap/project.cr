module MStrap
  class Project
    BOOTSTRAP_SCRIPT = File.join("script", "bootstrap")

    include Utils::System

    alias ProjectHash = Hash(String, Array(String) | String | Int32 | Nil)

    @cname : String
    @name : String
    @path : String
    @repo : String

    getter :name, :cname, :path, :repo

    def self.from_yaml(config_path)
      config = YAML.parse(File.read(config_path))
      raise "Not a valid project file" unless config["projects"]?
      config["projects"].as_a.map { |project| self.for(project) }
    end

    def self.for(project : YAML::Any)
      class_for(project["type"].as_s?).new(project)
    end

    def self.for(project : ProjectHash)
      class_for(project["type"].as?(String)).new(project)
    end

    def self.class_for(project_type)
      case project_type
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
      end
    end

    def initialize(project_config : YAML::Any)
      @name = project_config["name"].as_s
      @cname = project_config["cname"].as_s
      @path = File.join(MStrap::Paths::SRC_DIR, project_config["path"]? ? project_config["path"].as_s : cname)
      @repo = project_config["repo"].as_s
    end

    def initialize(project_config : ProjectHash)
      @name = project_config["name"].as(String)
      @cname = project_config["cname"].as(String)
      @path = File.join(MStrap::Paths::SRC_DIR, project_config["path"]? ? project_config["path"].as(String) : cname)
      @repo = project_config["repo"].as(String)
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

    def bootstrap(force_default = false)
      if File.exists?(File.join(path, BOOTSTRAP_SCRIPT)) && !force_default
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
