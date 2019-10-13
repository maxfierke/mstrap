module MStrap
  class CLI
    @config_def : Defs::ConfigDef?
    @options : CLIOptions
    @name : String?
    @email : String?
    @github : String?
    @github_access_token : String?

    getter :options

    def self.run!(args)
      new(args).run!
    end

    def initialize(args)
      @options = CLIOptions.new(argv: args.dup)

      OptionParser.new do |opts|
        opts.banner = "Usage: mstrap [options] <command> -- [<arguments>]"

        opts.on("-d", "--debug", "Run with debug messaging") do |debug|
          MStrap.debug = true
        end

        opts.on("-f", "--force", "Force overwrite of existing config with reckless abandon") do |force|
          options.force = true
        end

        opts.on(
          "-c",
          "--config-path [CONFIG_PATH]",
          "Path to configuration file\n\tDefault: #{MStrap::Paths::CONFIG_YML}. Can also be an HTTPS URL."
        ) do |config_path|
          options.config_path = config_path
        end

        opts.on(
          "-n",
          "--name NAME",
          "Your name (Default: prompt)\n\tCan also be specified by MSTRAP_USER_NAME env var."
        ) do |name|
          @name = name
        end

        opts.on(
          "-e",
          "--email EMAIL ADDRESS",
          "Email address (Default: prompt)\n\tCan also be specified by MSTRAP_USER_EMAIL env var."
        ) do |email|
          @email = email
        end

        opts.on(
          "-g",
          "--github GITHUB",
          "GitHub username (Default: prompt)\n\tCan also be specified by MSTRAP_USER_GITHUB env var."
        ) do |github|
          @github = github
        end

        opts.on(
          "-a",
          "--github-access-token [GITHUB_ACCESS_TOKEN]",
          "GitHub access token\n\tCan also be specified by MSTRAP_GITHUB_ACCESS_TOKEN env var.\n\tRequired for automatic fetching of personal dotfiles and Brewfile\n\tCan be omitted. Will pull from `hub` config, if available."
        ) do |token|
          @github_access_token = token
        end

        opts.on(
          "--skip-migrations",
          "Skip migrations"
        ) do |skip_migrations|
          options.skip_migrations = true
        end

        opts.on(
          "--skip-project-update",
          "Skip auto-update of projects"
        ) do |skip_project_update|
          options.skip_project_update = true
        end

        opts.on(
          "--skip-update",
          "Skip auto-update of mstrap"
        ) do |skip_update|
          options.skip_update = true
        end

        opts.on("-v", "--version", "Show version") do
          puts "mstrap v#{MStrap::VERSION}"
          exit
        end

        opts.on("-h", "--help", "Show this message") do
          puts "mstrap is a tool for bootstrapping development machines\n\n"
          puts opts
          puts "\nCOMMANDS"
          Step.all.each do |key, value|
            puts "    #{key}#{" " * (21 - key.to_s.size)}#{value.description}"
          end

          puts "\nRunning mstrap without a command will do a full bootstrap."

          exit
        end
      end.parse(args)
    end

    def run!
      configuration = Configuration.new(
        cli: options,
        config: config_def,
        github_access_token: @github_access_token
      )
      configuration.load_profiles!

      MStrap::Bootstrapper.new(configuration).bootstrap
    end

    private def config_def
      @config_def ||= if File.exists?(Paths::CONFIG_YML)
        config_yaml = File.read(Paths::CONFIG_YML)
        Defs::ConfigDef.from_yaml(config_yaml)
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
  end
end
