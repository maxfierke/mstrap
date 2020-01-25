module MStrap
  class CLI
    include Utils::Env
    include Utils::Logging

    # The default step run list. Running `mstrap` with no arguments
    # will run these steps in order.
    DEFAULT_STEPS = [
      :init,
      :dependencies,
      :shell,
      :services,
      :projects,
      :runtimes,
    ]

    PROJECT_RUNTIMES = [
      :unknown,
      :javascript,
      :python,
      :ruby,
    ]

    @config_def : Defs::ConfigDef?
    @cli : Commander::Command
    @options : CLIOptions
    @name : String?
    @email : String?
    @github : String?
    @github_access_token : String?

    getter :cli, :github_access_token, :options

    def self.run!(args)
      new(args).run!
    end

    def initialize(args)
      @options = CLIOptions.new(argv: args.dup)
      @cli = Commander::Command.new do |cmd|
        cmd.use = "mstrap"
        cmd.long = "mstrap is a tool for bootstrapping development machines"

        cmd.flags.add do |flag|
          flag.name = "config_path"
          flag.short = "-c"
          flag.long = "--config"
          flag.default = MStrap::Paths::CONFIG_HCL
          flag.description = "Path to configuration file. Can also be an HTTPS URL."
          flag.persistent = true
        end

        cmd.flags.add do |flag|
          flag.name = "debug"
          flag.short = "-d"
          flag.long = "--debug"
          flag.default = false
          flag.description = "Run with debug messaging."
          flag.persistent = true
        end

        cmd.flags.add do |flag|
          flag.name = "email"
          flag.long = "--email"
          flag.default = ""
          flag.description = "Email address (Default: config or prompt). Can also be specified by MSTRAP_USER_EMAIL."
        end

        cmd.flags.add do |flag|
          flag.name = "force"
          flag.short = "-f"
          flag.long = "--force"
          flag.default = false
          flag.description = "Force overwrite of existing config with reckless abandon."
          flag.persistent = true
        end

        cmd.flags.add do |flag|
          flag.name = "github"
          flag.long = "--github"
          flag.default = ""
          flag.description = "GitHub username. (Default: config or prompt). Can also be specified by MSTRAP_USER_GITHUB."
        end

        cmd.flags.add do |flag|
          flag.name = "github_access_token"
          flag.long = "--github-access-token"
          flag.default = ""
          flag.description = "GitHub access token. Can also be specified by MSTRAP_GITHUB_ACCESS_TOKEN. Required for automatic fetching of personal dotfiles and Brewfile. Can be omitted. Will pull from `hub` config, if available."
        end

        cmd.flags.add do |flag|
          flag.name = "name"
          flag.long = "--name"
          flag.default = ""
          flag.description = "Your name. (Default: config or prompt). Can also be specified by MSTRAP_USER_NAME."
        end

        cmd.flags.add do |flag|
          flag.name = "skip_project_update"
          flag.long = "--skip-project-update"
          flag.default = false
          flag.description = "Skip auto-update of projects."
          flag.persistent = true
        end

        Step.all.each do |key, step|
          cmd.commands.add do |cmd|
            cmd.use = key.to_s
            cmd.short = step.description
            cmd.long = step.long_description
            step.setup_cmd!(cmd)

            cmd.run do |options, arguments|
              validate_step!(key)

              load_cli_options!(options)
              config = load_configuration!

              run_step!(key, config, args: arguments)
              success "`mstrap #{key}` has completed successfully!"
              print_shell_reload_warning if step.requires_shell_restart?
            end
          end
        end

        cmd.commands.add do |project_cmd|
          project_cmd.use = "project"
          project_cmd.short = "Provisions a single mstrap project"
          project_cmd.long = <<-HELP
          #{project_cmd.short}. When run from within a project's script/bootstrap
            or script/setup it will run the standard mstrap project bootstrapping
            conventions.
          HELP

          project_cmd.run do |options, arguments|
            load_cli_options!(options)
            config = load_configuration!

            unless arguments.empty?
              project_cname = arguments[0]
              project_def = config
                .resolved_profile
                .projects
                .find { |proj| proj.cname == project_cname }
            end

            project_def ||= Defs::ProjectDef.new
            project_def.run_scripts = !ENV["__MSTRAP_EXEC_SCRIPTS"]
            project_def.cname = options.string["cname"] if options.string.has_key?("cname")
            project_def.name = options.string["name"] if options.string.has_key?("name")
            project_def.hostname = options.string["hostname"] if options.string.has_key?("hostname")
            project_def.path = options.string["path"] if options.string.has_key?("path")
            project_def.port = options.int["port"].to_i64 if options.string.has_key?("port")
            project_def.repo = options.string["repo"] if options.string.has_key?("repo")
            project_def.runtimes = options.string["runtimes"].split(',') if options.string.has_key?("runtimes")

            project = MStrap::Project.for(project_def)
            project.bootstrap
          end
        end

        cmd.commands.add do |version_cmd|
          version_cmd.use = "version"
          version_cmd.short = "Prints version number."
          version_cmd.long = version_cmd.short
          version_cmd.run do |options, arguments|
            puts "mstrap v#{MStrap::VERSION}"
            exit
          end
        end

        cmd.run do |options, arguments|
          load_cli_options!(options)
          config = load_configuration!

          logw "Strap in!"
          DEFAULT_STEPS.each { |s| run_step!(s, config) }
          success "mstrap has completed successfully!"
          print_shell_reload_warning
        end
      end
    end

    def run!
      Commander.run(cli, options.argv)
    end

    private def config_def
      @config_def ||= if options.config_path.starts_with?("https://")
                        CACertInstaller.install!
                        Defs::ConfigDef.from_url(options.config_path)
                      elsif File.exists?(options.config_path)
                        config_hcl = File.read(options.config_path)
                        Defs::ConfigDef.from_hcl(config_hcl)
                      else
                        Defs::ConfigDef.new(
                          user: Defs::UserDef.new(
                            name: name.not_nil!,
                            email: email.not_nil!,
                            github: github.not_nil!
                          ),
                        )
                      end.not_nil!
    end

    private def load_cli_options!(options)
      MStrap.debug = options.bool["debug"]
      self.options.config_path = options.string["config_path"]
      self.options.force = options.bool["force"]
      self.options.skip_project_update = options.bool["skip_project_update"]

      if options.string.has_key?("email") && !options.string["email"].empty?
        @email = options.string["email"]
      end

      if options.string.has_key?("github") && !options.string["github"].empty?
        @github = options.string["github"]
      end

      if options.string.has_key?("name") && !options.string["name"].empty?
        @name = options.string["name"]
      end

      @github_access_token = options.string["github_access_token"]?
    end

    private def load_configuration!
      configuration = Configuration.new(
        cli: options,
        config: config_def,
        github_access_token: github_access_token
      )
      configuration.load_profiles!

      configuration
    end

    private def name
      @name ||= ENV["MSTRAP_USER_NAME"]? ||
                ask("What is your name (First and Last)?")
    end

    private def email
      @email ||= ENV["MSTRAP_USER_EMAIL"]? || ask("What is your email?")
    end

    private def github
      @github ||= ENV["MSTRAP_USER_GITHUB"]? ||
                  ask("What is your GitHub username?")
    end

    private def ask(question = "", default = nil)
      question += " (Default: #{default})" if default
      question += ": "
      response = Readline.readline(question, true).not_nil!.squeeze(' ').strip
      if response && response.size > 0
        response
      else
        default
      end
    end

    private def print_shell_reload_warning
      logw "Remember to restart your terminal, as the contents of your environment may have shifted."
    end

    private def run_step!(step, config, args = [] of String)
      Step.all[step].new(
        config,
        args: args
      ).bootstrap
    end

    private def validate_step!(step)
      if Step.all[step].requires_mstrap? && !mstrapped?
        logc "You must do a full mstrap run before you can run `mstrap #{step}`"
      end
    end
  end
end
