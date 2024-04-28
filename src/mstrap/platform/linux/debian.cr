module MStrap
  module Linux
    module Debian
      extend DSL

      def self.has_git?
        has_command?("git")
      end

      def self.install_packages!(packages : Array(String))
        cmd("apt-get", ["-y", "install"] + packages, sudo: true)
      end

      def self.package_installed?(package_name : String)
        cmd("dpkg-query -W -f='${Status}' #{package_name} | grep -q 'ok installed'", quiet: true)
      end
    end
  end
end
