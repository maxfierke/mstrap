module MStrap
  module Runtimes
    # Go runtime management implmentation. It contains methods for interacting
    # with Go via the chosen runtime manager and bootstrapping a Go project
    # based on conventions.
    class Go < Runtime
      # :nodoc:
      GO_INSTALL_MIN_VERSION = SemanticVersion.new(1, 16, 0)

      def language_name : String
        "go"
      end

      def bootstrap
        if File.exists?("go.mod")
          runtime_exec "go mod download"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        packages.all? do |pkg|
          cmd_args =
            if SemanticVersion.parse(runtime_version) >= GO_INSTALL_MIN_VERSION
              ["install"]
            else
              ["get", "-u"]
            end

          if version = pkg.version
            cmd_args << "#{pkg.name}@#{version}"
          else
            cmd_args << pkg.name
          end

          disable_go_modules do
            runtime_exec "go", cmd_args, runtime_version: runtime_version
          end
        end
      end

      def matches? : Bool
        [
          "go.mod",
          ".go-version",
        ].any? do |file|
          File.exists?(file)
        end
      end

      private def disable_go_modules(&)
        current_module_setting = ENV["GO111MODULE"]?

        begin
          ENV["GO111MODULE"] = "off"
          yield
        ensure
          ENV["GO111MODULE"] = current_module_setting
        end
      end
    end
  end
end
