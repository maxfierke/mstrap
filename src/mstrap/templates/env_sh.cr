module MStrap
  # :nodoc:
  module Templates
    class EnvSh
      ECR.def_to_s "#{__DIR__}/env.sh.ecr"

      getter :shell_name
      getter :runtime_manager

      def initialize(@shell_name : String, @runtime_manager : RuntimeManager)
      end

      def needs_homebrew_shellenv?
        {{ flag?(:linux) || (flag?(:aarch64) && flag?(:darwin)) }}
      end
    end
  end
end
