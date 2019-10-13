module MStrap
  module Paths
    RC_DIR = File.join(ENV["HOME"], ".mstrap")
    SRC_DIR = File.join(ENV["HOME"], "src")
    XDG_CONFIG_DIR = File.join(ENV["HOME"], ".config")

    BREWFILE = File.join(RC_DIR, "Brewfile")
    CONFIG_YML = File.join(RC_DIR, "config.yml")
    PROFILE_YML = File.join(RC_DIR, "profile.yml")
    HUB_CONFIG_XML = File.join(XDG_CONFIG_DIR, "hub")
    LOG_FILE = File.join(RC_DIR, "mstrap.log")
    PROFILES_DIR = File.join(RC_DIR, "profiles")
    PROJECT_SITES = File.join(RC_DIR, "project-sites")
    PROJECT_SOCKETS = File.join(PROJECT_SITES, "sockets")
    SERVICES_INTERNAL_YML = File.join(RC_DIR, "services-internal.yml")
    SERVICES_YML = File.join(RC_DIR, "services.yml")
    STRAP_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "strap.sh")
    STRAP_SH_URL = "https://raw.githubusercontent.com/MikeMcQuaid/strap/master/bin/strap.sh"
  end
end
