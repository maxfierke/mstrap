module MStrap
  module Runtimes
    # Ruby runtime management implmentation. It contains methods for interacting
    # with Ruby via the chosen runtime manager and bootstrapping a Ruby project
    # based on conventions.
    class Ruby < Runtime
      def bootstrap
        if File.exists?("gems.rb") || File.exists?("Gemfile")
          runtime_exec "bundle install" unless runtime_exec "bundle check"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        packages.all? do |pkg|
          cmd_args = ["install", pkg.name]

          if version = pkg.version
            cmd_args << "-v"
            cmd_args << version
          end

          runtime_exec "gem", cmd_args, runtime_version: runtime_version
        end
      end

      def matches? : Bool
        [
          "Gemfile.lock",
          "Gemfile",
          "gems.rb",
          "gems.locked",
          ".ruby-version",
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
