module MStrap
  class CLI
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
        opts.banner = "Usage: mstrap [options]"

        opts.on("-d", "--debug", "Run with debug messaging") do |debug|
          MStrap.debug = true
        end

        opts.on("-f", "--force", "Force overwrite of existing config with reckless abandon") do |force|
          options.force = true
        end

        opts.on(
          "-c",
          "--config-path [CONFIG_PATH]",
          "Path to configuration file\n\tDefault: #{MStrap::Paths::CONFIG_YML}"
        ) do |config_path|
          options.config_path = config_path
        end

        opts.on(
          "-n",
          "--name NAME",
          "Your name (Default: prompt)\n\tCan also be specified by MSTRAP_USER_FULLNAME env var."
        ) do |name|
          @name = name
        end

        opts.on(
          "-e",
          "--email EMAIL ADDRESS",
          "Email address\n\tCan also be specified by MSTRAP_USER_EMAIL env var.\n\tWill prompt if name was not given"
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
          puts opts
          exit
        end
      end.parse(args)
    end

    def run!
      user = User.new(
        name: name.not_nil!,
        email: email.not_nil!,
        github: github.not_nil!,
        github_access_token: @github_access_token
      )
      configuration = Configuration.new(
        cli: options,
        user: user,
      )

      configuration.load_profile!

      MStrap::Bootstrapper.new(configuration).bootstrap
    end

    private def name
      @name ||= ENV["MSTRAP_USER_FULLNAME"]? ||
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
