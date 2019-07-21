module MStrap
  class CLIOptions
    @argv : Array(String)
    @step_args : Array(String)?
    @force = false
    @config_path = MStrap::Paths::CONFIG_YML
    @skip_migrations = false
    @skip_project_update = false
    @skip_update = false

    getter :argv
    property :config_path, :step_args
    property? :force,
      :skip_migrations,
      :skip_project_update,
      :skip_update

    def initialize(@argv)
    end
  end
end
