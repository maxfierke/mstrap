module MStrap
  module Projects
    class PythonProject < Project
      include Utils::Pyenv

      def bootstrap(*args)
        with_project_python { super }
      end

      protected def default_bootstrap
        super

        Dir.cd(path) do
          setup_pyenv
        end
      end
    end
  end
end
