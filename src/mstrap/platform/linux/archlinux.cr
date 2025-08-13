module MStrap
  module Linux
    module Archlinux
      extend DSL

      def self.install_packages!(packages : Array(String))
        cmd("pacman", ["-Sy", "--noconfirm", "--needed"] + packages, sudo: true)
      end

      def self.uninstall_packages!(packages : Array(String))
        cmd("pacman", ["-R", "--noconfirm"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("pacman", ["-Qi", package_name], quiet: true)
      end
    end
  end
end
