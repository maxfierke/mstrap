module MStrap
  module Projects
    class JavascriptProject < Project
      include Utils::Nodenv

      def bootstrap
        with_project_node { super }
      end

      protected def default_bootstrap
        Dir.cd(path) do
          setup_nodenv
        end

        super
      end
    end
  end
end
