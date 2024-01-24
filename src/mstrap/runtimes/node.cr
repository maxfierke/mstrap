module MStrap
  module Runtimes
    # Node runtime management implmentation. It contains methods for interacting
    # with Node via the chosen runtime manager and bootstrapping a Node project
    # based on conventions.
    class Node < Runtime
      def language_name : String
        "node"
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

        skip_reshim { runtime_exec "npm", cmd_args, runtime_version: runtime_version }
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

      private def skip_reshim(&)
        ENV["ASDF_SKIP_RESHIM"] = "1"
        yield
      ensure
        ENV.delete("ASDF_SKIP_RESHIM")
        runtime_exec "asdf", ["reshim", "nodejs"]
      end
    end
  end
end
