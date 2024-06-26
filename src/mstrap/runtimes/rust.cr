module MStrap
  module Runtimes
    # Rust runtime management implmentation. It contains methods for interacting
    # with Rust via the chosen runtime manager and bootstrapping a Rust project
    # based on conventions.
    class Rust < Runtime
      def current_version
        # Falling back to latest is _usually_ safe
        super || latest_version
      end

      def bootstrap
        if File.exists?("Cargo.toml")
          runtime_exec "cargo fetch"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        packages.all? do |pkg|
          cmd_args = ["install", pkg.name]

          if version = pkg.version
            cmd_args << "--version"
            cmd_args << version
          end

          runtime_exec "cargo", cmd_args, runtime_version: runtime_version
        end
      end

      def matches? : Bool
        [
          "Cargo.toml",
          ".rust-version",
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
