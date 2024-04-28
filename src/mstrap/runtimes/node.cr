module MStrap
  module Runtimes
    # Node runtime management implmentation. It contains methods for interacting
    # with Node via the chosen runtime manager and bootstrapping a Node project
    # based on conventions.
    class Node < Runtime
      def bootstrap
        if File.exists?("pnpm-lock.yaml") || File.exists?("pnpm-workspace.yaml")
          cmd("brew install pnpm", quiet: true) unless has_command?("pnpm")
          skip_reshim { runtime_exec "pnpm install" }
        elsif File.exists?("yarn.lock")
          cmd("brew install yarn", quiet: true) unless has_command?("yarn")
          skip_reshim { runtime_exec "yarn install" }
        elsif File.exists?("package.json")
          skip_reshim { runtime_exec "npm install" }
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
          "pnpm-lock.yaml",
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
        runtime_exec "asdf", ["reshim", "nodejs"] if runtime_manager.name == "asdf"
      end
    end
  end
end
