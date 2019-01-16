module MStrap
  class Project
    include Utils::System

    @hostname : String
    @name : String
    @path : String

    getter :name, :cname, :path, :hostname, :repo

    def self.from_yaml(config_path)
      config = YAML.parse(File.read(config_path))
      raise "Not a valid project file" unless config["projects"]?
      config["projects"].as_a.map { |project| self.for(project) }
    end

    def self.for(project)
      case project["type"].as(String?)
      when "ember-cli"
        Projects::EmberCLIProject
      # when "phoenix"
      #   PhoenixProject
      when "rails"
        Projects::RailsProject
      else
        Project
      end.new(project)
    end

    def initialize(project_config = {} of String => String | Int32)
      @name = project_config["name"].as(String)
      @cname = project_config["cname"].as(String)
      @path = "#{MStrap::Paths::SRC_DIR}/#{project_config["path"].as(String?) || cname}"
      @repo = project_config["repo"].as(String)
      @hostname = project_config["hostname"].as(String?) || "#{cname}.localhost"
    end

    def git_uri
      @git_uri ||= "git@github.com:#{repo}.git"
    end

    def clone
      cmd("git", "clone", git_uri, path)
    end

    def bootstrap
      if File.exists?(File.join(path, "script", "bootstrap"))
        Dir.cd(path) do
          cmd "script/bootstrap"
        end
      else
        MStrap::ProjectBootstrapper.new(self).bootstrap
      end
    end

    def nginx_upstream
      # This shouldn't be necessary but there seems to be a compiler bug
      nil
    end
  end
end
