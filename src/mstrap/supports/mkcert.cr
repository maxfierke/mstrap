module MStrap
  # Manages the integration with mkcert for issuing localhost certificates
  class Mkcert
    include DSL

    # Returns whether mkcert is installed
    def installed?
      cmd("command -v mkcert", quiet: true)
    end

    # Runs mkcert install process to add CARoot, etc.
    def install!
      install_dependencies!
      unless cmd("mkcert -install")
        logc "An error occurred while setting up Mkcert"
      end
    end

    # Installs a new mkcert for a hostname, with an optional wildcard version
    # (enabled by default)
    def install_cert!(hostname, wildcard = true)
      args = [hostname]
      args << "*.#{hostname}" if wildcard
      unless cmd("mkcert", args)
        logc "An error occurred while making a cert for #{hostname}"
      end
    end

    private def install_dependencies! : Nil
      {% if flag?(:linux) %}
        nss_package_name = MStrap::Linux.debian_distro? ? "libnss3-tools" : "nss-tools"

        return if MStrap::Linux.package_installed?(nss_package_name)

        unless MStrap::Linux.install_package!(nss_package_name)
          logc "Could not install '#{nss_package_name}' support package for mkcert"
        end
      {% end %}
    end
  end
end
