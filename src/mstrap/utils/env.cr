module MStrap
  module Utils
    module Env
      def debug?
        MStrap.debug?
      end

      def mstrapped?
        ENV["MSTRAP"]? == "true"
      end
    end
  end
end
