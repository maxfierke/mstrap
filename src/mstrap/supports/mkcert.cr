module MStrap
  # Manages the integration with mkcert for issuing localhost certificates
  class Mkcert
    include DSL

    # Returns whether mkcert is installed
    def installed?
      has_command?("mkcert")
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
      nss_package_name =
        {% if flag?(:linux) %}
          if MStrap::Linux.arch_distro?
            "nss"
          elsif MStrap::Linux.debian_distro?
            "libnss3-tools"
          else
            "nss-tools"
          end
        {% elsif flag?(:darwin) %}
          "nss"
        {% else %}
          {{ raise "Unsupported platform" }}
        {% end %}

      return if MStrap::Platform.package_installed?(nss_package_name)

      unless MStrap::Platform.install_package!(nss_package_name)
        logc "Could not install '#{nss_package_name}' support package for mkcert"
      end
    end
  end
end
