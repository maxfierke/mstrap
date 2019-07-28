module MStrap
  module Projects
    class RubyProject < Project
      include Utils::Rbenv

      def bootstrap
        with_project_ruby { super }
      end

      protected def default_bootstrap
        Dir.cd(path) do
          setup_rbenv
        end

        super
      end
    end
  end
end
