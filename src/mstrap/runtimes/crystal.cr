module MStrap
  module Runtimes
    # Crystal runtime management implmentation. It contains methods for interacting
    # with Crystal via ASDF and bootstrapping a Crystal project based on conventions.
    class Crystal < Runtime
      class SetupError < RuntimeSetupError
        def initialize(message)
          super("crystal", message)
        end
      end

      def language_name : String
        "crystal"
      end

      def current_version
        # Falling back to the latest is usually fairly safe
        super || latest_version
      end

      def bootstrap
        if File.exists?("shard.lock")
          cmd "shards check || shards install", quiet: true
        end
      end

      def install_packages(packages : Array(Defs::PkgDef), runtime_version : String? = nil) : Bool
        # No-op if empty, or fail as `shards` doesn't have a concept of global installs
        if packages.empty?
          true
        else
          raise_setup_error!("shards does not have global packages")
        end
      end

      def matches? : Bool
        [
          "shard.yml",
          "shard.lock",
          ".crystal-version",
        ].any? do |file|
          File.exists?(file)
        end
      end
    end
  end
end
