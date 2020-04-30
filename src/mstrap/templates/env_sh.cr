module MStrap
  # :nodoc:
  module Templates
    class EnvSh
      ECR.def_to_s "#{__DIR__}/env.sh.ecr"

      def needs_linuxbrew
        {{ flag?(:linux) }}
      end
    end
  end
end
