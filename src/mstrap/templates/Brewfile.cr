module MStrap
  # :nodoc:
  module Templates
    class Brewfile
      ECR.def_to_s "#{__DIR__}/Brewfile.ecr"

      getter :runtime_manager

      def initialize(@runtime_manager : RuntimeManager)
      end
    end
  end
end
