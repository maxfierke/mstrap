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

      def asdf_pre_version_install
        log "--> Ensure node.js release team keyring is up-to-date: "
        unless cmd "bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring", quiet: true
          logc "There was an error updating the node.js release team keyring. Check #{MStrap::Paths::LOG_FILE} or run again with --debug"
        end
        success "OK"
      end

      def bootstrap
        if File.exists?("yarn.lock")
          cmd "brew install yarn", quiet: true
          skip_reshim { cmd "yarn install", quiet: true }
        elsif File.exists?("package.json")
          skip_reshim { cmd "npm install", quiet: true }
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

        skip_reshim { asdf_exec "npm", cmd_args, runtime_version: runtime_version }
      end

      def matches? : Bool
        [
          "yarn.lock",
          "package.json",
          ".node-version",
        ].any? do |file|
          File.exists?(file)
        end
      end

      private def skip_reshim
        begin
          ENV["ASDF_SKIP_RESHIM"] = "1"
          yield
        ensure
          ENV.delete("ASDF_SKIP_RESHIM")
          asdf_exec "asdf", ["reshim", "nodejs"]
        end
      end
    end
  end
end
