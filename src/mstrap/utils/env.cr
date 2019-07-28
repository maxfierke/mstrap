module MStrap
  module Utils
    module Env
      def debug?
        MStrap.debug?
      end

      def logger
        MStrap.logger
      end

      def mstrapped?
        ENV["MSTRAP"]? == "true"
      end
    end
  end
end
