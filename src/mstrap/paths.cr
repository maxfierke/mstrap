module MStrap
  module Paths
    RC_DIR = File.join(ENV["HOME"], ".mstrap")
    SRC_DIR = File.join(ENV["HOME"], "src")

    CONFIG_YML = File.join(RC_DIR, "config.yml")
    LOG_FILE = File.join(RC_DIR, "mstrap.log")
    PROJECT_SOCKETS = File.join(RC_DIR, "project-sockets")
    SERVICES_YML = File.join(RC_DIR, "services.yml")
  end
end
