module MStrap
  module Paths
    # Path to runtime configuration directory
    RC_DIR = File.join(ENV["HOME"], ".mstrap")

    # Path to source code directory. Projects are stored here.
    SRC_DIR = File.join(ENV["HOME"], "src")

    # :nodoc:
    XDG_CONFIG_DIR = File.join(ENV["HOME"], ".config")

    # Path to default profile Brewfile
    BREWFILE = File.join(RC_DIR, "Brewfile")

    # Path to mstrap configuration file
    CONFIG_YML = File.join(RC_DIR, "config.yml")

    # :nodoc:
    HUB_CONFIG_XML = File.join(XDG_CONFIG_DIR, "hub")

    # Path to mstrap log file
    LOG_FILE = File.join(RC_DIR, "mstrap.log")

    # Path to mstrap profiles directory, where managed profiles are stored.
    PROFILES_DIR = File.join(RC_DIR, "profiles")

    # Path to project sites directory, where NGINX configurations are stored.
    PROJECT_SITES = File.join(RC_DIR, "project-sites")

    # Path to project sockets directory, where NGINX UNIX sockets are stored.
    PROJECT_SOCKETS = File.join(PROJECT_SITES, "sockets")

    # :nodoc:
    SERVICES_INTERNAL_YML = File.join(RC_DIR, "services-internal.yml")

    # Path to default profile `services.yml`, a docker-compose file.
    SERVICES_YML = File.join(RC_DIR, "services.yml")

    # :nodoc:
    STRAP_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "strap.sh")

    # :nodoc:
    STRAP_SH_URL = "https://raw.githubusercontent.com/MikeMcQuaid/strap/master/bin/strap.sh"
  end
end
