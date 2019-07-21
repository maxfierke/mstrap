module MStrap
  module Projects
    class RubyProject < Project
      include Utils::Rbenv

      def bootstrap(*args)
        with_project_ruby { super }
      end

      protected def default_bootstrap
        super

        Dir.cd(path) do
          setup_rbenv
        end
      end
    end
  end
end
