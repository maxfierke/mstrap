module MStrap
  module Utils
    module Env
      # Alias for `MStrap.debug?`
      def debug?
        MStrap.debug?
      end

      def has_git?
        ENV["MSTRAP_IGNORE_GIT"]? != "true" && (`command -v git` && $?.success?)
      end

      # Alias for `MStrap.logger`
      def logger
        MStrap.logger
      end

      # Returns whether or not the `mstrap` environment file (`env.sh`) has been
      # loaded into the environment.
      def mstrapped?
        ENV["MSTRAP"]? == "true"
      end
    end
  end
end
