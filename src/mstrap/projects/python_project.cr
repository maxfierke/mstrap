module MStrap
  module Projects
    class PythonProject < Project
      include Utils::Pyenv

      def bootstrap
        with_project_python { super }
      end

      protected def default_bootstrap
        Dir.cd(path) do
          setup_pyenv
        end

        super
      end
    end
  end
end
