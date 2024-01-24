module MStrap
  module Runtimes
    # PHP runtime management implmentation. It contains methods for interacting
    # with PHP via the chosen runtime manager and bootstrapping a PHP project
    # based on conventions.
    class Php < Runtime
      def language_name : String
        "php"
      end

      def bootstrap
        if File.exists?("composer.json")
          cmd "brew install composer", quiet: true
          cmd "composer install", quiet: true
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        cmd_args = ["global", "require"]

        packages.each do |pkg|
          if pkg.version
            cmd_args << "#{pkg.name}@#{pkg.version}"
          else
            cmd_args << pkg.name
          end
        end

        runtime_exec "composer", cmd_args, runtime_version: runtime_version
      end

      def matches? : Bool
        [
          "composer.json",
          "composer.lock",
          ".php-version",
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
