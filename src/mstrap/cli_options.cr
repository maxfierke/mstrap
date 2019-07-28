module MStrap
  class CLIOptions
    @argv : Array(String)
    @force = false
    @config_path = MStrap::Paths::CONFIG_YML
    @skip_migrations = false
    @skip_project_update = false
    @skip_update = false

    getter :argv
    property :config_path
    property? :force,
      :skip_migrations,
      :skip_project_update,
      :skip_update

    def initialize(@argv)
    end
  end
end
