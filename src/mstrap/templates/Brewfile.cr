module MStrap
  # :nodoc:
  module Templates
    class Brewfile
      ECR.def_to_s "#{__DIR__}/Brewfile.ecr"

      getter :default_runtime_manager

      def initialize(@default_runtime_manager : RuntimeManager)
      end
    end
  end
end
