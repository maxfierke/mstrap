module MStrap
  module Runtimes
    # Python runtime management implmentation. It contains methods for interacting
    # with Python via ASDF and bootstrapping a Python project based on conventions.
    #
    # TODO: Does not support virtualenv
    class Python < Runtime
      def language_name : String
        "python"
      end

      def bootstrap
        if File.exists?("requirements.txt")
          cmd "pip install -r requirements.txt"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        cmd_args = ["install", "-U"]

        packages.each do |pkg|
          if pkg.version
            cmd_args << "#{pkg.name}==#{pkg.version}"
          else
            cmd_args << pkg.name
          end
        end

        asdf_exec "pip", cmd_args, runtime_version: runtime_version
      end

      def matches? : Bool
        [
          "requirements.txt",
          ".python-version"
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
