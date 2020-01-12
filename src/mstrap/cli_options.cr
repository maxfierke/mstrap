module MStrap
  class CLIOptions
    @argv : Array(String)
    @force = false
    @config_path = MStrap::Paths::CONFIG_HCL
    @skip_project_update = false

    getter :argv
    property :config_path
    property? :force,
      :skip_project_update

    def initialize(@argv)
    end
  end
end
