module MStrap
  module Projects
    class RailsProject < WebProject
      include Utils::Rbenv

      def bootstrap(*args)
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
