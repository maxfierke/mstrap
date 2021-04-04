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

    @config_def : Defs::ConfigDef?
    @cli : Commander::Command
    @options : CLIOptions
    @name : String?
    @email : String?
    @github : String?

    getter :cli, :options

    def self.run!(args)
      new(args).run!
    end

    def initialize(args)
      @options = CLIOptions.new(argv: args.dup)
      @cli = Commander::Command.new do |cmd|
        cmd.use = "mstrap"

        # TODO: Use heredoc. Bug in Crystal 0.35.1 formatted required workaround
        cmd.long = "mstrap is a tool for bootstrapping development machines\n\n  Version v#{MStrap::VERSION} \n  Compiled at #{MStrap::COMPILED_AT}\n\n  Documentation: https://mstrap.dev/docs\n  Issue tracker: https://github.com/maxfierke/mstrap/issues"

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

              cli_options = load_cli_options!(options)
              config = load_configuration!

              run_step!(key, config, cli_options, args: arguments)
              success "`mstrap #{key}` has completed successfully!"
              print_shell_reload_warning if step.requires_shell_restart?
            end
          end
        end

        cmd.commands.add do |project_cmd|
          project_cmd.use = "project CNAME"
          project_cmd.short = "Provisions a single mstrap project"
          project_cmd.long = <<-HELP
          #{project_cmd.short}. When run from within a project's script/bootstrap
            or script/setup, it will run the standard mstrap project bootstrapping
            conventions.
          HELP

          project_cmd.flags.add do |flag|
            flag.name = "cname"
            flag.long = "--cname"
            flag.default = ""
            flag.description = "Project canonical name, e.g. my_cool_app"
          end

          project_cmd.flags.add do |flag|
            flag.name = "hostname"
            flag.long = "--hostname"
            flag.default = ""
            flag.description = "Project hostname. Defaults to CNAME.localhost. e.g. my_cool_app.localhost"
          end

          project_cmd.flags.add do |flag|
            flag.name = "name"
            flag.long = "--name"
            flag.default = ""
            flag.description = "Friendly project name, e.g. My Cool App"
          end

          project_cmd.flags.add do |flag|
            flag.name = "port"
            flag.long = "--port"
            flag.default = 0
            flag.description = "Port number"
          end

          project_cmd.flags.add do |flag|
            flag.name = "path"
            flag.long = "--path"
            flag.default = ""
            flag.description = "Project path, e.g. my-app-repo/backend"
          end

          project_cmd.flags.add do |flag|
            flag.name = "repo"
            flag.long = "--repo"
            flag.default = ""
            flag.description = "Git repository URL or GitHub path. Defaults to GITHUB_USERNAME/CNAME"
          end

          project_cmd.flags.add do |flag|
            flag.name = "runtimes"
            flag.long = "--runtimes"
            flag.default = ""
            flag.description = "Comma-seperated list of project runtimes. Will be detected if omitted."
          end

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
            project_def.port = options.int["port"].to_i64 if options.int.has_key?("port")
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
          cli_options = load_cli_options!(options)
          load_bootstrap_options!(options)

          config = load_configuration!

          logw "Strap in!"
          DEFAULT_STEPS.each { |s| run_step!(s, config, cli_options) }
          success "mstrap has completed successfully!"
          print_shell_reload_warning
        end
      end
    end

    def run!
      # Setup signal traps so that our `at_exit` hooks run
      # Needed until https://github.com/crystal-lang/crystal/issues/8687 is resolved
      Signal::INT.trap { exit 1 }
      Signal::TERM.trap { exit 1 }

      Commander.run(cli, options.argv)
    end

    private def config_def
      @config_def ||=
        if options.config_path.starts_with?("https://")
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
              github: github
            ),
          )
        end.not_nil!
    end

    private def load_cli_options!(options)
      MStrap.debug = options.bool["debug"] if options.bool.has_key?("debug")
      self.options.config_path = options.string["config_path"] if options.string.has_key?("config_path")
      self.options.force = options.bool["force"] if options.bool.has_key?("force")
      self.options.skip_project_update = options.bool["skip_project_update"] if options.bool.has_key?("skip_project_update")

      MStrap.initialize_logger!

      self.options
    end

    private def load_bootstrap_options!(options)
      if options.string.has_key?("email") && !options.string["email"].empty?
        @email = options.string["email"]
      end

      if options.string.has_key?("github") && !options.string["github"].empty?
        @github = options.string["github"]
      end

      if options.string.has_key?("name") && !options.string["name"].empty?
        @name = options.string["name"]
      end

      self
    end

    private def load_configuration!
      is_remote_config_path = options.config_path.starts_with?("https://")

      config_path = if is_remote_config_path
                      Paths::CONFIG_HCL
                    else
                      options.config_path
                    end

      configuration = Configuration.new(
        config: config_def,
        config_path: config_path
      )

      if is_remote_config_path
        if File.exists?(config_path) && !confirm_config_replace?(config_path, options.config_path)
          logc "Aborting due to existing configuration and choice not to replace."
        end

        # Download and save remote config
        configuration.save!
      end

      configuration.load_profiles!(force: options.force?)

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

    private def confirm_config_replace?(config_path, new_config_path)
      return true unless STDIN.tty?

      config_path = config_path.gsub(ENV["HOME"], "~")

      logn "There is already a configuration at #{config_path}, but you have "
      logn "requested to replace with one from '#{new_config_path}'."
      log "Do you want to continue and replace the existing configuration (Y/n)?: "

      input = nil

      loop do
        input = STDIN.gets
        input = input.strip if input
        break if ["Y", "n"].includes?(input)
      end

      input == "Y"
    end

    private def print_shell_reload_warning
      logw "Remember to restart your terminal, as the contents of your environment may have shifted."
    end

    private def run_step!(step, config, cli_options, args = [] of String)
      Step.all[step].new(
        config,
        cli_options,
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
