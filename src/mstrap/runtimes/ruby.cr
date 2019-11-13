module MStrap
  module Runtimes
    # Ruby runtime management implmentation. It contains methods for interacting
    # with Ruby via ASDF and bootstrapping a Ruby project based on conventions.
    class Ruby < Runtime
      def language_name : String
        "ruby"
      end

      def bootstrap
        if File.exists?("gems.rb")
          cmd "gem install bundler"
          cmd "bundle check || bundle install"
        elsif File.exists?("Gemfile")
          cmd "gem install bundler"
          cmd "gem install bundler -v '<2'"
          cmd "bundle check || bundle install"
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        packages.all? do |pkg|
          cmd_args = ["install", pkg.name]

          if version = pkg.version
            cmd_args << "-v"
            cmd_args << version
          end

          asdf_exec "gem", cmd_args, runtime_version: runtime_version
        end
      end

      def matches? : Bool
        [
          "Gemfile.lock",
          "Gemfile",
          "gems.rb",
          "gems.locked",
          ".ruby-version"
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end