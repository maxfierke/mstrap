module MStrap
  class ProjectCLI
    PROJECT_RUNTIMES = [
      :unknown,
      :javascript,
      :python,
      :ruby,
    ]

    def self.run!(args)
      new(args).run!
    end

    def initialize(args)
      @project_def = Defs::ProjectDef.new

      OptionParser.new do |opts|
        opts.banner = "Usage: mstrap-project [options]"

        opts.on(
          "--path PATH",
          "Project Path\n\te.g. my-app-repo/backend"
        ) do |path|
          project_def.path = path
        end

        opts.on(
          "-p",
          "--port PORT",
          "Port Number\n\te.g. 3000"
        ) do |port|
          project_def.port = port.to_i
        end

        opts.on(
          "-n",
          "--name NAME",
          "Friendly Project name\n\te.g. My Cool App"
        ) do |name|
          project_def.name = name
        end

        opts.on(
          "-c",
          "--cname CNAME",
          "Project Canonical Name\n\te.g. my_cool_app"
        ) do |cname|
          project_def.cname = cname
        end

        opts.on(
          "-t",
          "--runtime RUNTIME",
          "Project Runtime\n\tOne of #{PROJECT_RUNTIMES.map(&.to_s).join(", ")}"
        ) do |runtimes|
          project_def.runtimes = runtimes.split(',')
        end

        opts.on(
          "-h",
          "--hostname [HOSTNAME]",
          "Project Hostname (Default: CNAME.localhost)\n\te.g. my_cool_app.localhost"
        ) do |hostname|
          project_def.hostname = hostname
        end

        opts.on(
          "-r",
          "--repo [REPO]",
          "Git Repository Name (Default: GITHUB_USERNAME/CNAME)",
        ) do |repo|
          project_def.repo = repo
        end

        opts.on("--help", "Show this message") do
          puts opts
          exit 0
        end
      end.parse(args)

      # Since we're likely running from a project script, we don't want to start
      # a fork-bomb, now do we?
      project_def.run_scripts = false
    end

    def run!
      MStrap.debug = true

      # Save terminal status on exit
      # stty_save = %x`stty -g`.chomp
      # trap("INT") { print "\n"; system "stty", stty_save; exit 1 }

      project = MStrap::Project.for(project_def)
      project.bootstrap
    end

    private getter :project_def
  end
end
