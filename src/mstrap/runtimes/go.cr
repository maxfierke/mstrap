module MStrap
  module Runtimes
    # Go runtime management implmentation. It contains methods for interacting
    # with Go via ASDF and bootstrapping a Go project based on conventions.
    class Go < Runtime
      def asdf_plugin_name : String
        "golang"
      end

      def language_name : String
        "go"
      end

      def bootstrap
        if File.exists?("go.mod")
          cmd "go mod download", quiet: true
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        packages.all? do |pkg|
          cmd_args = ["get", "-u"]

          if version = pkg.version
            cmd_args << "#{pkg.name}@#{version}"
          else
            cmd_args << pkg.name
          end

          disable_go_modules do
            asdf_exec "go", cmd_args, runtime_version: runtime_version
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

      private def disable_go_modules
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
