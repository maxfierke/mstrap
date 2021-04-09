module MStrap
  module Darwin
    module MacOS
      extend DSL

      def self.install_packages!(packages : Array(String))
        cmd("brew", ["install"] + packages)
      end

      def self.package_installed?(package_name : String)
        cmd("brew list | grep -q '^#{package_name}$'", quiet: true)
      end
    end
  end
end
