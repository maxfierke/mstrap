module MStrap
  module Runtimes
    # PHP runtime management implmentation. It contains methods for interacting
    # with PHP via ASDF and bootstrapping a PHP project based on conventions.
    class Php < Runtime
      def language_name : String
        "php"
      end

      def bootstrap
        if File.exists?("composer.json")
          cmd "brew install composer"
          cmd "composer install"
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

        cmd "composer", cmd_args
      end

      def matches? : Bool
        [
          "composer.json",
          "composer.lock",
          ".php-version"
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
