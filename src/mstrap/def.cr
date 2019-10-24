module MStrap
  module Defs
    # :nodoc:
    abstract class Def
      abstract def merge!(other : self)

      def merge!(others : Array(self))
        others.each { |other| merge!(other) }
      end
    end
  end
end
