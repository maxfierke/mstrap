module MStrap
  class ProjectCLI
    PROJECT_TYPES = [:rails, :phoenix, :"ember-cli", :generic]

    getter :options

    def self.run!(args)
      new(args).run!
    end

    def initialize(args)
      @options = {} of String => Nil | Int32 | String | Array(String)

      OptionParser.new do |opts|
        opts.banner = "Usage: mstrap-project [options]"

        opts.on(
          "--path PATH",
          "Project Path\n\te.g. my-app-repo/backend"
        ) do |path|
          options["path"] = path
        end

        opts.on(
          "-p",
          "--port PORT",
          "Port Number\n\te.g. 3000"
        ) do |port|
          options["port"] = port
        end

        opts.on(
          "-n",
          "--name NAME",
          "Friendly Project name\n\te.g. My Cool App"
        ) do |name|
          options["name"] = name
        end

        opts.on(
          "-c",
          "--cname CNAME",
          "Project Canonical Name\n\te.g. my_cool_app"
        ) do |cname|
          options["cname"] = cname
        end

        opts.on(
          "-t",
          "--type TYPE",
          "Project Type\n\tOne of #{PROJECT_TYPES.map(&.to_s).join(", ")}"
        ) do |t|
          options["type"] = t
        end

        opts.on(
          "-h",
          "--hostname [HOSTNAME]",
          "Project Hostname (Default: CNAME.localhost)\n\te.g. my_cool_app.localhost"
        ) do |hostname|
          options["hostname"] = hostname
        end

        opts.on(
          "-r",
          "--repo [REPO]",
          "Git Repository Name (Default: GITHUB_USERNAME/CNAME)",
        ) do |repo|
          options["repo"] = repo
        end

        opts.on("--help", "Show this message") do
          puts opts
          exit 0
        end
      end.parse(args)
    end

    def run!
      MStrap.debug = true

      # Save terminal status on exit
      # stty_save = %x`stty -g`.chomp
      # trap("INT") { print "\n"; system "stty", stty_save; exit 1 }

      project = MStrap::Project.for(options)
      MStrap::ProjectBootstrapper.new(project).bootstrap
    end
  end
end
