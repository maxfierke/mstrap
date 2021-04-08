module MStrap
  module Linux
    module Fedora
      extend Utils::Logging
      extend Utils::System
      extend RHEL

      def self.install_packages!(packages : Array(String))
        cmd("dnf", ["-y", "install"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("dnf", ["info", "--installed", package_name], quiet: true)
      end
    end
  end
end
