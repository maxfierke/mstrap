module MStrap
  module Linux
    module Fedora
      extend DSL
      extend RHEL

      def self.has_git?
        has_command?("git")
      end

      def self.install_packages!(packages : Array(String))
        cmd("dnf", ["-y", "install"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("dnf", ["info", "--installed", package_name], quiet: true)
      end
    end
  end
end
