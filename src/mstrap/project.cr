module MStrap
  class Project
    include Utils::System

    @name : String
    @path : String

    getter :name, :cname, :path, :repo

    def self.from_yaml(config_path)
      config = YAML.parse(File.read(config_path))
      raise "Not a valid project file" unless config["projects"]?
      config["projects"].as_a.map { |project| self.for(project) }
    end

    def self.for(project)
      case project["type"].as(String?)
      when "rails"
        Projects::RailsProject
      when "web"
        Projects::WebProject
      else
        Project
      end.new(project)
    end

    def initialize(project_config = {} of String => String | Int32)
      @name = project_config["name"].as(String)
      @cname = project_config["cname"].as(String)
      @path = "#{MStrap::Paths::SRC_DIR}/#{project_config["path"].as(String?) || cname}"
      @repo = project_config["repo"].as(String)
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
  end
end
