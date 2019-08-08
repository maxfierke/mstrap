module MStrap
  class WebBootstrapper
    include Utils::System

    getter :project

    def initialize(@project : Project)
    end

    def bootstrap
      Templates::NginxConf.new(project).write_to_config!
    end
  end
end
