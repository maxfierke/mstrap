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

    # Path to curl's CA cert bundle (used for verifying certs)
    CA_CERT_BUNDLE = File.join(RC_DIR, "cacert.pem")

    # Path to mstrap configuration file
    CONFIG_HCL = File.join(RC_DIR, "config.hcl")

    # Path to mstrap log file
    LOG_FILE = File.join(RC_DIR, "mstrap.log")

    # Path to mstrap profiles directory, where managed profiles are stored.
    PROFILES_DIR = File.join(RC_DIR, "profiles")

    # Path to project certs directory, where NGINX TLS certs are stored.
    PROJECT_CERTS = File.join(RC_DIR, "project-certs")

    # Path to project sites directory, where NGINX configurations are stored.
    PROJECT_SITES = File.join(RC_DIR, "project-sites")

    # Path to project sockets directory, where NGINX UNIX sockets are stored.
    PROJECT_SOCKETS = File.join(PROJECT_SITES, "sockets")

    # :nodoc:
    SERVICES_INTERNAL_YML = File.join(RC_DIR, "services-internal.yml")

    # Path to default profile `services.yml`, a Docker Compose file.
    SERVICES_YML = File.join(RC_DIR, "services.yml")

    # :nodoc:
    STRAP_SH_PATH = File.join(MStrap::Paths::RC_DIR, "vendor", "strap.sh")

    {% if flag?(:darwin) %}
      # :nodoc:
      STRAP_SH_URL = "https://raw.githubusercontent.com/MikeMcQuaid/strap/main/strap.sh"

      {% if flag?(:aarch64) %}
        # :nodoc:
        HOMEBREW_PREFIX = ENV["HOMEBREW_PREFIX"]? || "/opt/homebrew"
      {% else %}
        # :nodoc:
        HOMEBREW_PREFIX = ENV["HOMEBREW_PREFIX"]? || "/usr/local"
      {% end %}
    {% elsif flag?(:linux) %}
      # :nodoc:
      STRAP_SH_URL = "https://raw.githubusercontent.com/maxfierke/strap-linux/master/bin/strap.sh"

      # :nodoc:
      HOMEBREW_PREFIX = ENV["HOMEBREW_PREFIX"]? || "/home/linuxbrew/.linuxbrew"
    {% end %}
  end
end
