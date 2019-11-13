module MStrap
  module Runtimes
    # Node runtime management implmentation. It contains methods for interacting
    # with Node via ASDF and bootstrapping a Node project based on conventions.
    class Node < Runtime
      def asdf_plugin_name
        "nodejs"
      end

      def language_name : String
        "node"
      end

      def setup
        super
        cmd "bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring"
      end

      def bootstrap
        if File.exists?("yarn.lock")
          cmd "brew install yarn"
          cmd "yarn install"
        elsif File.exists?("package.json")
          cmd "npm install"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        cmd_args = ["install", "-g"]

        packages.each do |pkg|
          if pkg.version
            cmd_args << "#{pkg.name}@#{pkg.version}"
          else
            cmd_args << pkg.name
          end
        end

        asdf_exec "npm", cmd_args, runtime_version: runtime_version
      end

      def matches? : Bool
        [
          "Gemfile.lock",
          "Gemfile",
          "gems.rb",
          "gems.locked",
          ".ruby-version"
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
