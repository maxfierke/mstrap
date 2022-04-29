module MStrap
  # :nodoc:
  module Templates
    class EnvSh
      ECR.def_to_s "#{__DIR__}/env.sh.ecr"

      def needs_homebrew_shellenv?
        {{ flag?(:linux) || (flag?(:aarch64) && flag?(:darwin)) }}
      end
    end
  end
end
