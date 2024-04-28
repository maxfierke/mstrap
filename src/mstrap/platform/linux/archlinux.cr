module MStrap
  module Linux
    module Archlinux
      extend DSL

      def self.has_git?
        has_command?("git")
      end

      def self.install_packages!(packages : Array(String))
        cmd("pacman", ["-Sy", "--noconfirm", "--needed"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("pacman", ["-Qi", package_name], quiet: true)
      end
    end
  end
end
