module MStrap
  module Paths
    RC_DIR = File.join(ENV["HOME"], ".mstrap")
    SRC_DIR = File.join(ENV["HOME"], "src")

    BREWFILE = File.join(RC_DIR, "Brewfile")
    CONFIG_YML = File.join(RC_DIR, "config.yml")
    LOG_FILE = File.join(RC_DIR, "mstrap.log")
    PROJECT_SOCKETS = File.join(RC_DIR, "project-sockets")
    SERVICES_YML = File.join(RC_DIR, "services.yml")
    STRAP_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "strap.sh")
    STRAP_SH_URL = "https://raw.githubusercontent.com/MikeMcQuaid/strap/master/bin/strap.sh"
  end
end
