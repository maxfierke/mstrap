module MStrap
  module Defs
    # :nodoc:
    abstract class Def
      include HCL::Serializable

      abstract def merge!(other : self)

      def merge!(others : Array(self))
        others.each { |other| merge!(other) }
      end
    end
  end
end
