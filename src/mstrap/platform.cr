module MStrap
  module Platform
    {% if flag?(:linux) %}
      extend ::MStrap::Linux
    {% elsif flag?(:darwin) %}
      extend ::MStrap::Darwin
    {% else %}
      {{ raise "Unsupported platform" }}
    {% end %}

    # Indicates whether the host platform has Git installed
    def self.has_git?
      ENV["MSTRAP_IGNORE_GIT"]? != "true" && (`command -v git` && $?.success?)
    end

    # Installs a list of packages using the platform's package manager
    def self.install_packages!(packages : Array(String))
      platform.install_packages!(packages)
    end

    # Installs a single package using the platform's package manager
    def self.install_package!(package_name : String)
      platform.install_packages!([package_name])
    end

    # Install a single package using the platform's package manager
    def self.package_installed?(package_name : String)
      platform.package_installed?(package_name)
    end
  end
end
