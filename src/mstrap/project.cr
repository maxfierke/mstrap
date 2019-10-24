module MStrap
  class Project
    include Utils::Logging
    include Utils::Env
    include Utils::Node
    include Utils::Php
    include Utils::Python
    include Utils::Ruby
    include Utils::System

    # :nodoc:
    ABSOLUTE_REPO_URL_REGEX = /\A(git|https?|ftps?|ssh|file):\/\//

    # :nodoc:
    SCP_REPO_REGEX = /\A(.+@)?[\w\d\.\-_]+:/

    # :nodoc:
    BOOTSTRAP_SCRIPT = File.join("script", "bootstrap")

    # :nodoc:
    SETUP_SCRIPT = File.join("script", "setup")

    @cname : String
    @hostname : String
    @name : String
    @path : String
    @port : Int32?
    @repo : String
    @run_scripts : Bool
    @runtime : String
    @upstream : String?
    @websocket : Bool
    @web : Bool

    # Returns canonical name for the project. This must be unique among projects.
    getter :cname

    # Returns hostname for the project.
    getter :hostname

    # Returns friendly display name for the project.
    getter :name

    # Returns path to the project on the filesystem.
    getter :path

    # Returns the port for the project, if configured.
    getter :port

    # Returns the configured GitHub path or URI for the project's repo.
    getter :repo

    # Returns the primary language runtime of the project, if specified.
    getter :runtime

    # Returns whether to execute and scripts-to-rule-them-all scripts, if they exist.
    getter? :run_scripts

    # Returns whether the project is a web project.
    getter? :web

    # Returns whether the project requires a websocket connection
    getter? :websocket

    # Factory constructor for `Project` from a project definition
    def self.for(project_def : Defs::ProjectDef)
      Project.new(project_def)
    end

    protected def initialize(project_def : Defs::ProjectDef)
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

    # Returns a usable Git URI for the project
    def git_uri
      @git_uri ||= if repo =~ ABSOLUTE_REPO_URL_REGEX || repo =~ SCP_REPO_REGEX
        repo
      else
        "git@github.com:#{repo}.git"
      end
    end

    # Returns the NGINX upstream for the project. Relevant only to web projects.
    def upstream
      @upstream ||= begin
        if port = @port
          "host.docker.internal:#{port}"
        else
          "unix:#{Paths::PROJECT_SOCKETS}/#{cname}"
        end
      end
    end

    # Whether project has any bootstrapping/setup scripts a-la
    # [`scripts-to-rule-them-all`](https://github.com/github/scripts-to-rule-them-all)
    def has_scripts?
      [BOOTSTRAP_SCRIPT, SETUP_SCRIPT].any? do |script_path|
        File.exists?(File.join(path, script_path))
      end
    end

    # Clones the project from Git
    def clone
      cmd("git", "clone", git_uri, path, quiet: true)
    end

    # Updates the project from Git, including auto-stashing any unstaged and
    # uncommited changes.
    def pull
      Dir.cd(path) do
        git_checkpoint do
          success = if current_branch != "master"
            cmd("git checkout master", quiet: true) && cmd("git pull origin master --rebase", quiet: true) && cmd("git checkout -", quiet: true)
          else
            cmd "git pull origin master --rebase", quiet: true
          end

          unless success
            logw "Failed to update 'master' branch from remote. There may be a problem that needs to be resolved manually."
          end

          success
        end
      end
    end

    # Executes `script/bootstrap` and `script/setup` (if either exists and are
    # configured to run) or executes conventional runtime bootstrapping as
    # determined by mstrap.
    def bootstrap
      if has_scripts? && run_scripts?
        logd "Found bootstrapping scripts, executing instead of using '#{runtime}' defaults."
        Dir.cd(path) do
          cmd BOOTSTRAP_SCRIPT if File.exists?(BOOTSTRAP_SCRIPT)
          cmd SETUP_SCRIPT if File.exists?(SETUP_SCRIPT)
        end
      else
        logd "Bootstrapping '#{name}' with runtime '#{runtime}' defaults."
        default_bootstrap
      end
    end

    # Conventional bootstrapping from mstrap. This will auto-detect the runtimes
    # used by the project and run the standard bootstrapping for each runtime.
    # This **does not** run any bootstrapping scripts, and is used mainly for
    # calling into conventional bootstrapping within a project's
    # `script/bootstrap` or `script/setup` from `mstrap-project`.
    protected def default_bootstrap
      if node?
        logd "Detected Node. Installing Node."
        setup_node
      end

      if php?
        logd "Detected PHP. Installing PHP and any composer dependencies."
        setup_php
      end

      if python?
        logd "Detected Python. Installing Python and any pip dependencies."
        setup_python
      end

      if ruby?
        logd "Detected Ruby. Installing Ruby, bundler, and any Gemfile dependencies."
        setup_ruby
      end

      if web?
        logd "'#{name}' is a web project. Running web bootstrapper."
        WebBootstrapper.new(self).bootstrap
      end
    end

    private def current_branch
      `git rev-parse --abbrev-ref HEAD`.chomp
    end

    private def git_checkpoint
      stash_message = "MSTRAP CHECKPOINT #{Time.utc.to_unix}"

      begin
        cmd("git", "stash", "push", "-u", "-m", stash_message, quiet: true)
        yield
      ensure
        if cmd("git stash list | grep '#{stash_message}'", quiet: true)
          cmd "git stash pop", quiet: true
        end
      end
    end
  end
end
