module MStrap
  module Linux
    module RHEL
      extend Utils::Logging
      extend Utils::System

      def self.install_packages!(packages : Array(String))
        cmd("yum", ["-y", "install"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("yum", ["info", "--installed", package_name], quiet: true)
      end
    end
  end
end
