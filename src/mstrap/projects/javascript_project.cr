module MStrap
  module Projects
    class JavascriptProject < Project
      include Utils::Nodenv

      def bootstrap(*args)
        with_project_node { super }
      end

      protected def default_bootstrap
        super

        Dir.cd(path) do
          setup_nodenv
        end
      end
    end
  end
end
